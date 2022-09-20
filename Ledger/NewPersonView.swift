//
//  NewPersonView.swift
//  Ledger
//
//  Created by Riya Manchanda on 28/04/21.
//

import SwiftUI

struct NewPersonView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var persons: FetchedResults<Contact>
    
    @Binding var isDisplayed: Bool
    
    @State var name = ""
    @State var nameFieldShake = false
    @State var showSamePersonAlert = false
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            if !UIDevice.current.orientation.isLandscape {
                Text("Add New Person")
                    .padding(.vertical, 15)
                    .font(.custom("Roboto-Bold", size: 20))
                    .foregroundColor(Color("Title"))
            }
        
            FirstResponderTextField(text: $name, placeholder: "Enter Name")
                .frame(height: 30)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Color("Title"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .modifier(ShakeEffect(shakes: nameFieldShake ? 2 : 0))
                .animation(nameFieldShake ? Animation.default.repeatCount(3).speed(3) : nil)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .border(nameFieldShake ? Color.red : Color.clear, width: 2)
            
            
            Divider()
            
            HStack {
                
                Spacer()
                
                Button(action: {
                    
                    self.nameFieldShake = false
                    
                    guard self.name != "" else {
                        self.nameFieldShake = true
                        return
                    }
                    
                    if persons.first(where: {$0.name.lowercased() == self.name.lowercased()}) != nil {
                        showSamePersonAlert.toggle()
                    } else {
                        let newPerson = Contact(context: viewContext)
                        newPerson.name = self.name
                        newPerson.id = UUID()
                        do {
                            try viewContext.save()
                            self.isDisplayed = false
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                   
                }) {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                }
                
                .alert(isPresented: $showSamePersonAlert) {
                    Alert(title: Text("Person Already Exists"),
                          message: Text("A person with name \(self.name) already exists. Please use a different name for this contact."),
                          dismissButton: .cancel())
                }
                
                Spacer()
                Divider()
                Button (action: {
                    self.isDisplayed = false
                }) {
                    HStack {
                        Spacer()
                        Text("Cancel")
                        Spacer()
                    }
                }
                
                Spacer()
                
            }
        }.frame(width: 300, height: !UIDevice.current.orientation.isLandscape ? 200 : 100)
        .padding(20)
        
    }
    
    init(isDisplayed: Binding<Bool>, persons: FetchedResults<Contact>) {
        self._isDisplayed = isDisplayed
        self.persons = persons
        UITableView.appearance().backgroundColor = .clear
    }
}
