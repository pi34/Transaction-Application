//
//  HomeView.swift
//  Ledger
//
//  Created by Riya Manchanda on 13/05/21.
//

import SwiftUI

struct AllTileView: View {
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
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
                
                    VStack(alignment: .leading, spacing: 5) {
                        Text(transaction.person.name)
                            .font(.custom("Roboto-Bold", size: 18))
                            .foregroundColor(Color("Items"))
                        Text(transaction.title)
                            .font(.custom("Roboto-Regular", size: 12))
                            .foregroundColor(Color("Subitems"))
                            .lineSpacing(4)
                    }
                    
                        Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(suffixNumber(number: NSNumber(value: transaction.amount)) as String)
                            .font(.custom("Roboto-Bold", size: 18))
                            .foregroundColor(transaction.amount >= 0 ? Color("Amount") : Color.red)
                        Text(formatDate(date: transaction.date))
                            .font(.custom("Open-Sans", size: 12))
                            .foregroundColor(Color("Subitems"))
                        
                    }
                    
                }.padding(.vertical, 7)
                .padding(.trailing, (UIApplication.shared.windows.first?.safeAreaInsets.right)! + 7)
                .padding(.leading, (UIApplication.shared.windows.first?.safeAreaInsets.left)! + 7)
                
            }
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

func getMonthAndYearBetween(start: Date, end: Date) -> [String] {
    let format = DateFormatter()
    format.dateFormat = "dd/MM/yyyy"
    
    let startDate = start
    let endDate = end

    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents(Set([.month]), from: startDate, to: endDate)

    var allDates: [String] = []
    let dateRangeFormatter = DateFormatter()
    dateRangeFormatter.dateFormat = "MMM yyyy"

    for i in 0 ... (components.month!+1) {
        guard let date = calendar.date(byAdding: .month, value: i, to: startDate) else {
        continue
        }

        let formattedDate = dateRangeFormatter.string(from: date)
        allDates += [formattedDate]
    }
    return allDates
}

func dateMonthFormat(date: Date) -> String {
    let dateRangeFormatter = DateFormatter()
    dateRangeFormatter.dateFormat = "MMM yyyy"
    return dateRangeFormatter.string(from: date)
}

struct HomeView: View {
    
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [NSSortDescriptor.init(key: "date", ascending: false)])

    var transactions: FetchedResults<Transaction>
    
    var sortDateItems = ["All", "This Week", "This Month", "This Year"]
    
    @State var showNewTransactionView = false
    @State var selectedFilter = "All"
    
    var body: some View {
        
        NavigationView {
            ZStack {
                
                VStack (alignment: .trailing) {
                    Picker(selection: $selectedFilter, label: Text("Filter Transactions by:")) {
                        ForEach(sortDateItems, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                    
                    if transactions.isEmpty {
                        List {
                            VStack {
                                Text("No Transactions Yet!")
                                    .font(.custom("OpenSans-Regular", size: 16))
                                    .padding(20)
                                    .foregroundColor(Color("Subitems"))
                            }
                        }
                    }
                    
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
                    
                    let lastTransaction = filteredTransactions.last
                    let array = getMonthAndYearBetween(start: lastTransaction?.date ?? now, end: now)
                    
                    GeometryReader { geometry in
                        ScrollView {
                            ScrollViewReader { value in
                                
                                if !transactions.isEmpty && selectedFilter != "This Week" && selectedFilter != "This Month" {
                                    HStack {
                                        
                                        Spacer()
                                        
                                        Menu {
                                                ForEach(0..<array.reversed().count, id: \.self) { idx in
                                                    
                                                    let monthTransactions = filteredTransactions.filter {
                                                        dateMonthFormat(date: $0.date) == array.reversed()[idx] }
                                                    
                                                    if !monthTransactions.isEmpty {
                                                        Button(action: {
                                                            withAnimation {
                                                                
                                                                value.scrollTo(array.reversed()[idx])
                                                            }
                                                        }, label: {
                                                            Text(array.reversed()[idx])
                                                                .padding(15)
                                                        })
                                                    }
                                                    
                                                }
                                            } label: {
                                                Label {
                                                    Text("Sort By Month")
                                                        .foregroundColor(.black)
                                                        .font(.system(size: 14))
                                                        .padding(10)
                                                        .background(Color.white)
                                                        .clipShape(Capsule())
                                                        .shadow(color: Color.black.opacity(0.4), radius: 0.5, x: 0, y: 0)
                                                } icon: {
                                                    Image(systemName: "calendar")
                                                        .foregroundColor(.black)
                                                }.padding(.vertical, 5)
                                                .padding(.bottom, 5)
                                            }
                                        .transition(.move(edge: .top))
                                        .animation(.default)
                                    }.padding(.trailing, 20)
                                }
                                
                                    List {
                                        ForEach (array.reversed(), id: \.self) { string in
                                            
                                            let monthTransactions = filteredTransactions.filter {
                                                dateMonthFormat(date: $0.date) == string }
                                            
                                            if !monthTransactions.isEmpty {
                                                Section(header: Text(string).font(.system(size: 12))) {
                                                    ForEach (monthTransactions) {
                                                            transaction in
                                                        if !transaction.isFault {
                                                            AllTileView(transaction: transaction)
                                                                .padding(.horizontal, 20)
                                                                .padding(.vertical, 6)
                                                        }
                                                    }
                                                }.id(string)
                                            }
                                        }
                                        
                                    }.frame(height: geometry.size.height)
                                
                            }
                        }
                    }
                    
                    .sheet(isPresented: $showNewTransactionView) {
                        NewTransactionView(title: (transactions.last)?.title ?? "New Payment")
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showNewTransactionView = true
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
            .navigationBarTitle("My Transactions")
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
