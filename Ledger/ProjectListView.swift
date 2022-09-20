//
//  ProjectListView.swift
//  Ledger
//
//  Created by Riya Manchanda on 15/05/21.
//

import SwiftUI

struct ProjectNameView: View {
    @State var name: String
    var amount: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.custom("Roboto-Bold", size: 20))
                .foregroundColor(Color("Items"))
            
            Spacer()
            
            Button (action: {}) {
                Text(amount)
                    .foregroundColor(Color("Amount"))
                    .font(.custom("Lato-Bold", size: 22))

            }
        }
        .padding(10)
    }
}

struct ProjectListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Project.entity(), sortDescriptors: [])

    var projects: FetchedResults<Project>
    
    @State var showNewProjectView = false
    @State var searchField: String = ""
    @State private var isEditing = false
    @State private var projectsViewId = UUID()
    
    var body: some View {
        
        NavigationView {
            ZStack {
                
                VStack {
                    
                    HStack {
                        TextField("Search", text: $searchField)
                            .frame(height: 30)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .padding(.horizontal, 25)
                            .foregroundColor(Color("Title"))
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(Color("Title"))
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 8)
                             
                                    if (self.searchField != "") {
                                        Button(action: {
                                                self.searchField = ""
                                            }) {
                                                Image(systemName: "multiply.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .padding(.trailing, 8)
                                            }
                                    }
                                }
                            ).onTapGesture {
                                self.isEditing = true
                            }
                        
                        if isEditing {
                            Button(action: {
                                self.isEditing = false
                                self.searchField = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

                    
                            }) {
                                Text("Cancel")
                            }
                            .padding(.trailing, 10)
                            .transition(.move(edge: .trailing))
                            .animation(.default)
                        }
                        
                    }.padding(.horizontal, 15)
                    .padding(.top, 15)
                
                    
                    List {
                        let filteredProjects = projects.filter {
                            searchField.isEmpty || $0.name.contains(searchField)
                        }
                        ForEach (filteredProjects, id: \.self) { project in
                            
                            ZStack {
                                NavigationLink (destination: ProjectPageView(project: project, amount: (projectAmount(project: project)))) { EmptyView() }
                                
                                ProjectNameView(name: project.name, amount: suffixNumber(number: NSNumber(value: projectAmount(project: project))) as String)
                                    
                                .contextMenu {
                                        Button(action: {
                                            delete(project: project)
                                        }) {
                                            Text("Delete")
                                        }
                                    }
                                    .padding(12)
                                    .padding(.trailing, 15)
                            }
                        }
                        
                        if filteredProjects.isEmpty {
                            if projects.isEmpty {
                                VStack {
                                    Text("No Groups Yet!")
                                        .font(.custom("OpenSans-Regular", size: 16))
                                        .padding(20)
                                        .foregroundColor(Color("Subitems"))
                                }
                            } else {
                                VStack {
                                    Text("No Groups Found!")
                                        .font(.custom("OpenSans-Regular", size: 16))
                                        .padding(20)
                                        .foregroundColor(Color("Subitems"))
                                }
                            }
                        }
                        
                    }
                    
                    .sheet(isPresented: $showNewProjectView) {
                        NewProjectView()
                            .environment(\.managedObjectContext, self.viewContext)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showNewProjectView = true
                        }, label: {
                            Text("+")
                                .font(.system(.largeTitle))
                                .frame(width: 77, height: 70)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 7)
                        })
                        .background(Color("Accent"))
                        .cornerRadius(38.5)
                        .padding(40)
                        .shadow(color: Color.black.opacity(0.3),
                            radius: 3,
                            x: 3,
                            y: 3)
                    }
                }
            }
            .navigationBarTitle("My Groups")
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func delete (project: Project) {
        viewContext.delete(project)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func projectAmount(project: Project) -> Float {
        let people = project.people.array as! [Contact]
        var amountTotal: [Float] = []
        for person in people {
            let transactions = (person.transactions?.array as! [Transaction])
            let amount = transactions.map{$0.amount} .reduce(0,+)
            amountTotal.append(amount)
        }
        return amountTotal.reduce(0,+)
    }
}
