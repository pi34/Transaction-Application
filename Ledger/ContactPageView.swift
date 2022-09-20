//
//  ContactPageView.swift
//  Ledger
//
//  Created by Riya Manchanda on 28/04/21.
//

import SwiftUI
import Foundation
import Combine

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 0)
    }
    
}

struct TotalCardView: View {
    
    var amount: Float
        
    var body: some View {
        HStack {
            
            Text("Total Amount:")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 7)
            Spacer()
            Text("\(suffixNumber(number: NSNumber(value: amount)))" as String)
                .font(.custom("Roboto-Bold", size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
            
        .background(Color("Accent"))
        .modifier(CardModifier())
        .padding(.horizontal, 20)
        .padding (.vertical, 15)
    }
}

struct TransactionTileView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @State var showDeleteSheet = false
    
    @ObservedObject var transaction: Transaction
    
    func delete (transaction: Transaction) {
        viewContext.delete(transaction)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        if transaction.isFault {
            EmptyView()
        } else {
            VStack(alignment: .center) {
                
                HStack(spacing: 20) {
                
                    VStack(alignment: .leading, spacing: 8) {
                        Text(transaction.title)
                            .font(.custom("Roboto-Medium", size: 16))
                            .foregroundColor(Color("Title"))
                            .lineSpacing(3)
                        Text("\(formatDate(date: transaction.date))")
                            .font(.custom("Open-Sans", size: 12))
                            .foregroundColor(Color("Subitems"))
                    }
                    
                        Spacer()
                    
                    let amount = suffixNumber(number: NSNumber(value: transaction.amount))
                    
                        Text("\(amount)" as String)
                        .font(.custom("Roboto-Bold", size: 20))
                            .foregroundColor(transaction.amount >= 0 ? Color("Amount") : Color.red)
                    
                }.padding(.vertical, 7)
                .padding(.trailing, (UIApplication.shared.windows.first?.safeAreaInsets.right)! + 7)
                .padding(.leading, (UIApplication.shared.windows.first?.safeAreaInsets.left)! + 7)
                
            }
            .padding(7)
            .contentShape(Rectangle())
            .onTapGesture {
                
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                showDeleteSheet.toggle()
            }
            
            .actionSheet(isPresented: $showDeleteSheet) {
                ActionSheet(
                    title: Text("Are you sure you want to Delete this Transaction?"),
                    buttons: [.default(Text("Delete Transaction")) {delete(transaction: transaction)}, .cancel()]
                )
            }
        }
    }
    
}

func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    return dateFormatter.string(from: date)
}

func dateSorted(array: [Transaction]) -> [Transaction] {
    let sorted_array = array.sorted {$0.date > $1.date}
    return sorted_array
}

struct ContactPageView: View {
    
    @ObservedObject var person: Contact
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var sortDateItems = ["All", "This Week", "This Month", "This Year"]
    
    @State var searchField: String = ""
    @State var showNewTransactionView = false
    @State private var isEditing = false
    @State var selectedFilter = "All"
    
    var body: some View {
        
        let transactions = (person.transactions?.array as! [Transaction])
        
        let now = Date()
        
        let filteredTransactions = transactions.filter {
            switch(selectedFilter) {
            case "All":
                return true
            case "This Week":
                return ($0.date).isInSameWeek(as: now)
            case "This Month":
                return ($0.date).isInSameMonth(as: now)
            case "This Year":
                return ($0.date).isInSameYear(as: now)
            default:
                return true
            }
        }
        
        let amount = filteredTransactions.map{$0.amount} .reduce(0,+)
        
        let formattedTransactions = dateSorted(array: filteredTransactions)
        
        let finalTransactions = formattedTransactions.filter {
            searchField.isEmpty || $0.title.contains(searchField) || formatDate(date: $0.date).contains(searchField)
        }
        
        
            
                VStack {
                    
                    if !self.isEditing {
                        Divider()
                        Picker(selection: $selectedFilter, label: Text("Filter Transactions by:")) {
                            ForEach(sortDateItems, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(10)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 0)
                        
                        if !UIDevice.current.orientation.isLandscape {
                            TotalCardView(amount: amount)
                                .transition(.move(edge: .top))
                                .animation(.default)
                        }
                    }
                    
                    VStack {
                        
                        if !UIDevice.current.orientation.isLandscape {
                            
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
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.top, 30)
                                    .padding(.leading, 10)
                                    .onTapGesture {
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
                                    .padding(.trailing, 20)
                                    .padding(.top, self.isEditing ? 30 : 0)
                                    .transition(.move(edge: .trailing))
                                    .animation(.default)
                                }
                            }
                            
                        }
                        
                        VStack (alignment: .center) {
                            
                            if !finalTransactions.isEmpty {
                                
                                List {
                                    ForEach (finalTransactions, id: \.self) {
                                        transaction in
                                        TransactionTileView(transaction: transaction)
                                    }
                                }
                                
                            } else {
                                VStack {
                                    Text("No Transactions Yet!")
                                        .font(.custom("OpenSans-Regular", size: 16))
                                        .padding(20)
                                        .foregroundColor(Color("Subitems"))
                                    
                                    Spacer()
                                }
                            }
                        }.transition(.move(edge: .bottom))
                        .animation(.easeInOut)
                            .padding(.leading, (UIApplication.shared.windows.first?.safeAreaInsets.left)! + 0)
                            .padding(.trailing, (UIApplication.shared.windows.first?.safeAreaInsets.right)! + 0)
                        
                    }
                    .background(Color.white)
                    .cornerRadius(30, corners: [.topRight, .topLeft])
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut)
                    
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
                
                Spacer()
            
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image("Back")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 16)
                    .imageScale(.large)
                    .foregroundColor(.black)
            }), trailing:  Button(action: {
                showNewTransactionView = true
            }, label: {
                Image(systemName: "plus")
                    .renderingMode(.template)
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
                    .frame(width: 35, height: 35)
            })
            
            .sheet(isPresented: $showNewTransactionView) {
                NewTransactionView(title: (person.transactions?.array.last as?  Transaction)?.title ?? "New Payment", person: person.name)
            })
                    
                    .navigationBarTitle(Text(person.name), displayMode: .inline)
        
            .navigationBarBackButtonHidden(true)
            
    }
    
}
