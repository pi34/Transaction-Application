//
//  ProjectPageView.swift
//  Ledger
//
//  Created by Riya Manchanda on 15/05/21.
//

import SwiftUI

struct ProjectPageView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var project: Project
    var amount: Float
    @State var showNewProjectView = false
    
    var body: some View {
        
        ZStack {
            VStack {
                    TotalCardView(amount: amount)
                    
                    ScrollView {
                        
                        let people = project.people.array as! [Contact]
                        
                        if people.isEmpty {
                            VStack {
                                Text("No People Yet!")
                                    .font(.custom("OpenSans-Regular", size: 16))
                                    .padding(20)
                                    .foregroundColor(Color("Subitems"))
                            }
                        }
                        
                        ForEach (people) { person in
                            
                            let transactions = (person.transactions?.array as! [Transaction])
                            let amountTotal = transactions.map{$0.amount} .reduce(0,+)
                            
                            NavigationLink (destination: ContactPageView(person: person)) {
                                VStack (alignment: .leading, spacing: 4) {
                                    Spacer()
                                    HStack {
                                        Text(person.name)
                                            .font(.custom("Roboto-Medium", size: 22))
                                            .foregroundColor(Color("Title"))
                                        
                                        Spacer()
                                        
                                        Text(suffixNumber(number: NSNumber(value: amountTotal)) as String)
                                            
                                            .font(.custom("Roboto-Bold", size: 20))
                                            .foregroundColor(Color("Amount"))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 7)
                                    
                                    Spacer()
                                    
                                    Divider()
                                    
                                    Spacer()
                                    
                                    HStack {
                                        if let date = transactions.last?.currentDate.timeAgoDisplay() {
                                            Text("Last Payment added: \(date)" as String)
                                                .font(.custom("Open-Sans", size: 14))
                                                .foregroundColor(Color("Subitems"))
                                                .padding(.horizontal, 20)
                                                .padding(.bottom, 20)
                                                
                                        } else {
                                            Text("No transactions yet!")
                                                .font(.custom("Open-Sans", size: 14))
                                                .foregroundColor(Color("Subitems"))
                                                .padding(.horizontal, 20)
                                                .padding(.bottom, 20)
                                        }
                                    }
                                    
                                }
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 0)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 5)
                            }
                        }
                    }
                }
            
            Spacer()
            
                .sheet(isPresented: $showNewProjectView) {
                    NewProjectView(project: project)
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
                            .foregroundColor(Color("Accent"))
                            .padding(.bottom, 7)
                    })
                    .background(Color.white)
                    .cornerRadius(38.5)
                    .padding(40)
                    .shadow(color: Color.black.opacity(0.3),
                        radius: 3,
                        x: 3,
                        y: 3)
                }
            }
        }
            .navigationTitle(project.name)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image("Back")
                    .resizable()
                    .frame(width: 24, height: 20)
                    .imageScale(.large)
            }))
        
            .navigationBarBackButtonHidden(true)
    }
}
