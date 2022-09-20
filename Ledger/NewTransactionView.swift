//
//  NewTransactionView.swift
//  Ledger
//
//  Created by Riya Manchanda on 29/04/21.
//

import SwiftUI
import Combine

struct ShakeEffect: GeometryEffect {
        func effectValue(size: CGSize) -> ProjectionTransform {
            return ProjectionTransform(CGAffineTransform(translationX: -30 * sin(position * 2 * .pi), y: 0))
        }
        
        init(shakes: Int) {
            position = CGFloat(shakes)
        }
        
        var position: CGFloat
        var animatableData: CGFloat {
            get { position }
            set { position = newValue }
        }
    }

struct NewTransactionView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    @FetchRequest(entity: Contact.entity(), sortDescriptors: [])

    var persons: FetchedResults<Contact>
    
    @State var selectedDate = Date()
    @State var amount = ""
    @State var title: String
    @State var showError = false
    @State var error: String = ""
    @State var person: String = ""
    
    @State var amountFieldShake = false
    @State var nameFieldShake = false
    @State var personFieldShake = false
    
    func addPerson (person: String) -> Contact {
        let newPerson = Contact(context: viewContext)
        newPerson.name = person
        newPerson.id = UUID()
        return newPerson
    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading, spacing: 20) {
                
                HStack {
                    
                    Button (action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Image("Back")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 24, height: 20)
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                    }.padding(20)
                    
                    Spacer()
                    
                    Text("New Transaction")
                        .font(.custom("Roboto-Bold", size: 20))
                        .foregroundColor(.white)
                        .padding(20)
                    
                    Spacer()
                    
                    Button(action: {
                        self.amountFieldShake = false
                        self.nameFieldShake = false
                        self.personFieldShake = false
                            
                        let decimalCharacters = CharacterSet.decimalDigits

                        let decimalRange = self.amount.rangeOfCharacter(from: decimalCharacters)

                        if decimalRange != nil {
                            guard self.amount != "" && Double(self.amount) != 0 else {
                                self.amountFieldShake = true
                                return
                            }
                        } else {
                            self.amountFieldShake = true
                            return
                        }
                        
                        guard self.title != "" else {
                            self.nameFieldShake = true
                            return
                        }
                        guard self.person != "" else {
                            self.personFieldShake = true
                            return
                        }
                        let newTransaction = Transaction(context: viewContext)
                        do {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            let nsNumber = formatter.number(from: self.amount)
                            try newTransaction.amount = nsNumber!.floatValue
                        } catch {
                            self.amountFieldShake = false
                            return
                        }
                        newTransaction.date = self.selectedDate
                        newTransaction.currentDate = Date()
                        newTransaction.title = self.title
                        if let person = persons.first(where: {$0.name.lowercased() == self.person.lowercased()}) {
                            newTransaction.person = person
                        } else {
                            newTransaction.person = addPerson(person: self.person)
                        }
                        newTransaction.id = UUID()
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
                            .foregroundColor(.white)
                    }
                    .padding(20)
                    
                }.background(Color("Title"))
                .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 0)
                
                VStack (spacing: 20) {
                    HStack {
                        Text("Date")
                            .font(.system(size: 18))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        Spacer()
                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                            .labelsHidden()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    let locale = Locale.current
                    let currencySymbol = locale.currencySymbol ?? ""
                    
                    FirstResponderTextField(text: $amount, placeholder: "\(currencySymbol) 0", keyboardType: .numbersAndPunctuation, font: UIFont(name: "Helvetica Neue Light", size: 60))
                        .modifier(ShakeEffect(shakes: amountFieldShake ? 2 : 0))
                        .animation(amountFieldShake ? Animation.default.repeatCount(4).speed(3) : nil)
                        .frame(width: 200, height: 70)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .border(amountFieldShake ? Color.red : Color.clear, width: 2)
                        .onReceive(Just(amount)) { newValue in
                            let filtered = newValue.filter { "-0123456789.".contains($0) }
                            var noOfPoints = 0
                            for char in filtered {
                                if char == "." {
                                    noOfPoints+=1
                                }
                            }
                            if noOfPoints > 1 {
                                self.amountFieldShake = true
                                return
                            }
                            if filtered != newValue {
                                self.amountFieldShake = true
                                return
                            }
                        }
                    
                    VStack (alignment: .leading) {
                        Text("Person:")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.systemGray2))
                        
                        TextField("Person", text: $person)
                            .font(.system(size: 18))
                            .modifier(ShakeEffect(shakes: personFieldShake ? 2 : 0))
                            .animation(personFieldShake ? Animation.default.repeatCount(4).speed(3) : nil)
                            .frame(height: 20)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .border(personFieldShake ? Color.red : Color.clear, width: 2)
                    }
                    
                    VStack (alignment: .leading) {
                        Text("Payment Title:")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.systemGray2))
                        
                        TextField("Payment Title", text: $title)
                            .font(.system(size: 18))
                            .modifier(ShakeEffect(shakes: nameFieldShake ? 2 : 0))
                            .animation(nameFieldShake ? Animation.default.repeatCount(4).speed(3) : nil)
                            .frame(height: 20)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .border(nameFieldShake ? Color.red : Color.clear, width: 2)
                    }
                    
                }.padding(.horizontal, 40)
                .padding(.top, 20)
                
            }
        }.accentColor(Color("Accent"))
    }
}
