//
//  NewProjectView.swift
//  Ledger
//
//  Created by Riya Manchanda on 15/05/21.
//

import SwiftUI

struct ChecklistItem: View {
    var person: Contact
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.person.name)
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(Color("Items"))
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
        }.padding(20)
        .listRowBackground(self.isSelected ? Color(UIColor.systemGray5) : Color.clear)
    }
}

struct NewProjectView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    @FetchRequest(entity: Contact.entity(), sortDescriptors: [])

    var people: FetchedResults<Contact>
    var project: Project?
    @State var name: String = ""
    @State var selected: [Contact] = []
    @State var searchText: String = ""
    @State var isEditing: Bool = false
    @State var titleFieldShake = false
    
    var body: some View {
        
        VStack {
            
            VStack {
                HStack {
                    
                    Button (action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("Back")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 20)
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if project != nil {
                        Text("Add People")
                            .font(.custom("Roboto-Bold", size: 20))
                            .foregroundColor(Color.white)
                    } else {
                        Text("Add New Group")
                            .font(.custom("Roboto-Bold", size: 20))
                            .foregroundColor(Color.white)
                    }
                    
                    Spacer()
                    
                    Button (action: {
                        if project == nil {
                            guard self.name != "" else {
                                self.titleFieldShake = true
                                return
                            }
                            let newProject = Project(context: viewContext)
                            newProject.name = self.name
                            for person in self.selected {
                                viewContext.performAndWait {
                                    person.project = newProject
                                    try? viewContext.save()
                                }
                            }
                            newProject.id = UUID()
                        } else {
                            for person in self.selected {
                                viewContext.performAndWait {
                                    person.project = project
                                    try? viewContext.save()
                                }
                            }
                        }
                        do {
                            try viewContext.save()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color.white)
                    }
                }
                .padding(20)
                .padding(.bottom, 0)
                
                if (project == nil) {
                    HStack {
                        FirstResponderTextField(text: $name, placeholder: "Group Name:")
                            .frame(height: 30)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .modifier(ShakeEffect(shakes: titleFieldShake ? 2 : 0))
                            .animation(Animation.default.repeatCount(3).speed(3))
                            .border(titleFieldShake ? Color.red : Color.clear, width: 2)
                    }
                        .padding(.horizontal, 15)
                    .padding(.bottom, 20)
                }
            }
            .background(Color("Title"))
            .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 0)
            
            HStack {
                TextField("Search", text: $searchText)
                    .frame(height: 30)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .padding(.horizontal, 25)
                    .foregroundColor(Color("Title"))
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 0)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("Title"))
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                     
                            if (self.searchText != "") {
                                Button(action: {
                                        self.searchText = ""
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
                        self.searchText = ""
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
            
            let persons = people.filter { $0.project == nil }
            
            List {
                ForEach (persons.filter {
                    searchText.isEmpty ||
                        ($0.name.lowercased().prefix(searchText.count) == searchText.lowercased())
                }, id: \.self) {
                    person in
                    
                    if (person.project == nil) {
                        
                        ChecklistItem(person: person, isSelected: self.selected.contains(person)) {
                            if (self.selected.contains(person)) {
                                if let index = selected.firstIndex(of: person) {
                                    selected.remove(at: index)
                                }
                            } else {
                                self.selected.append(person)
                            }
                        }
                    }
                }
                if persons.isEmpty {
                    VStack {
                        Text("No People Available")
                            .font(.custom("OpenSans-Regular", size: 16))
                            .padding(20)
                            .foregroundColor(Color("Subitems"))
                    }
                }
            }
        }.accentColor(Color("Accent"))
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
    }
}
