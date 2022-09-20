//
//  PeopleView.swift
//  Ledger
//
//  Created by Riya Manchanda on 19/05/21.
//

import SwiftUI

struct PeopleView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Contact.entity(), sortDescriptors: [])

    var persons: FetchedResults<Contact>
    
    @State var showNewPersonView = false
    @State var showModal: Bool = false
    @State var showDeleteSheet = false
    @State var searchText: String = ""
    @State var isEditing: Bool = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                VStack {
                    
                    HStack {
                        TextField("Search", text: $searchText)
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
                
                    let people = persons.sorted {
                            
                            switch (($0.transactions?.array.last as? Transaction)?.currentDate, ($1.transactions?.array.last as? Transaction)?.currentDate) {
                            
                            case (($0.transactions?.array.last as? Transaction)?.currentDate as Date, ($1.transactions?.array.last as? Transaction)?.currentDate as Date):
                                return ($0.transactions?.array.last as! Transaction).currentDate > ($1.transactions?.array.last as! Transaction).currentDate
                            case (nil, nil):
                                return false
                            case (nil, _):
                                return false
                            case (_, nil):
                                return true
                            default:
                                return true
                            }

                        }
                    
                        List {
                            
                            let filteredPeople = people.filter {
                                searchText.isEmpty ||
                                    ($0.name.lowercased().prefix(searchText.count) == searchText.lowercased())
                            }
                            
                            if people.isEmpty {
                                VStack {
                                    Text("No People Yet!")
                                        .font(.custom("OpenSans-Regular", size: 16))
                                        .padding(20)
                                        .foregroundColor(Color("Subitems"))
                                }
                            } else if filteredPeople.isEmpty {
                                VStack {
                                    Text("No People Found!")
                                        .font(.custom("OpenSans-Regular", size: 16))
                                        .padding(20)
                                        .foregroundColor(Color("Subitems"))
                                }
                            }
                            
                            ForEach( filteredPeople, id: \.self) { person in
                                
                                ZStack {
                                    NavigationLink(destination: ContactPageView(person: person)) { EmptyView() }
                                    VStack {
                                        if let transaction = person.transactions?.array as? [Transaction] {
                                            if transaction.last != nil {
                                                PersonTileView(person: person, setDate: true, date: transaction.last?.currentDate.timeAgoDisplay())
                                                    
                                            } else {
                                                PersonTileView(person: person, setDate:  false)
                                            }
                                        }
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            delete(person: person)
                                        }) {
                                            Text("Delete")
                                        }
                                    }
                                    .padding(12)
                                    .padding(.trailing, 15)
                                    
                                }
                                
                            }
                            
                        }
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showNewPersonView.toggle()
                        }, label: {
                            Text("+")
                                .font(.system(.largeTitle))
                                .frame(width: 77, height: 70)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 7)
                        })
                        .background(Color("Title"))
                        .cornerRadius(38.5)
                        .padding(40)
                        .shadow(color: Color.black.opacity(0.3),
                            radius: 3,
                            x: 3,
                            y: 3)
                    }
                }
            }
                .navigationBarTitle("My People")
                .modal(isPresented: $showNewPersonView) {
                    NewPersonView(isDisplayed: $showNewPersonView, persons: persons)
                        .environment(\.managedObjectContext, self.viewContext)
                }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func delete (person: Contact) {
        viewContext.delete(person)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
