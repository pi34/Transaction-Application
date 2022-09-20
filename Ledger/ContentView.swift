//
//  ContentView.swift
//  Ledger
//
//  Created by Riya Manchanda on 27/04/21.
//

import SwiftUI
import CoreData


struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.black), .font : UIFont(name:"Roboto-Bold", size: 32)!]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.black), .font : UIFont(name:"Roboto-Bold", size: 20)!]
    }
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        
        if currentPage > totalPages {
            TabView {
                
                PeopleView()
                    .tabItem {
                        Image(systemName: "person.fill")
                            .renderingMode(.template)
                        Text("People")
                    }
                
                HomeView()
                    .environment(\.managedObjectContext, self.viewContext)
                    .tabItem {
                        Image(systemName: "banknote.fill")
                            .renderingMode(.template)
                        Text("All")
                            .animation(.easeInOut) // 2
                            .transition(.slide)
                    }
                
                ProjectListView()
                    .tabItem {
                        Image(systemName: "pencil.slash")
                            .renderingMode(.template)
                        Text("Groups")
                    }
            }
            .accentColor(Color("Accent"))
            
            
        } else {
            WalkthroughScreen()
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
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

struct WalkthroughScreen: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        ZStack {
            
            if currentPage == 1 {
                ScreenView(image: "Onboarding1", image2: "", title: "Get Started", description: "Transaction provides you with a covenient and reliable tool to record transactions with other people and to keep track of your payments.")
                    .transition(.scale)
            }
            if currentPage == 2 {
                ScreenView(image: "Onboarding2", image2: "Onboarding3", title: "Record Payments", description: "Press on the '+' button on the bottom-right corner to start adding new transactions and recording them. Add negative values for recording payments received.")
                    .transition(.scale)
            }
            if currentPage == 3{
                ScreenView(image: "Onboarding4", image2: "Onboarding5", title: "Maintain Contacts", description: "Keep your payments sorted by each contact that you add. Add more contacts whenever you want.")
                    .transition(.scale)
            }
            if currentPage == 4 {
                ScreenView(image: "Onboarding6", image2: "Onboarding7", title: "Create Groups", description: "Group your contacts together and keep collective records of the total amount paid to the group! Keep your transactions organized!")
                    .transition(.scale)
            }
            
        }.overlay(
            Button(action: {
                withAnimation(.easeInOut) {
                    currentPage += 1
                }
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color("Accent"))
                    .clipShape(Circle())
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(Color.black.opacity(0.04), lineWidth: 4)
                            Circle()
                                .trim(from: 0, to: CGFloat(currentPage) / CGFloat(totalPages))
                                .stroke(Color("Accent"), lineWidth: 4)
                                .rotationEffect(.init(degrees: -90))
                        }
                        .padding(-15)
                    )
            })
            .padding(.bottom, 20)
            
            ,alignment: .bottom
        )
    }
}

func suffixNumber(number: NSNumber) -> NSString {

    var num:Double = number.doubleValue;
    let sign = ((num < 0) ? "-" : "" );
    
    let locale = Locale.current
    let currencySymbol = locale.currencySymbol ?? ""
    let code = locale.currencyCode ?? ""
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = locale

    num = fabs(num);

    if code == "INR" {
        if (num < 1000000.0){
            let newNum = (String(format: "\(currencySymbol) %.0f", num))
            return "\(sign)\(newNum)" as NSString;
        }
    } else {
        if (num < 1000000.0){
            let newNum = (String(format: "\(currencySymbol) %.2f", num))
            return "\(sign)\(newNum)" as NSString;
        }
    }

    if code == "INR" && (num >= 100000.0) && (num < 10000000.0){
        
        let finalNum: String = (String(format: "\(currencySymbol) %.2f", num/100000))
        return "\(sign)\(finalNum) Lacs" as NSString
        
    } else if code == "INR" && (num >= 10000000.0) {
        
        let finalNum: String = (String(format: "\(currencySymbol) %.2f", num/10000000))
        return "\(sign)\(finalNum) Cr" as NSString
        
    } else {
        
        let exp:Int = Int(log10(num) / 5.0 ); //log10(1000));

        let units:[String] = ["M","G","T","P","E"];

        let roundedNum:Double = round(10 * num / pow(1000000.0,Double(exp))) / 10;
        let finalNum: String = (String(format: "\(currencySymbol) %.2f", roundedNum))
        return "\(sign)\(finalNum)\(units[exp-1])" as NSString;
        
    }

}

struct ScreenView: View {
    
    var image: String
    var image2: String
    var title: String
    var description: String
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                if currentPage == 1 {
                    Text("Welcome")
                        .font(.custom("Roboto-Bold", size: 30))
                        .foregroundColor(Color("Title"))
                } else {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            currentPage -= 1
                        }
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color("Title"))
                            .cornerRadius(10)
                    })
                }
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut) {
                        currentPage = 5
                    }
                }, label: {
                    Text("Skip")
                        .fontWeight(.semibold)
                })
            }
            .foregroundColor(.black)
            .padding()
            
            Spacer(minLength: 0)
            
            HStack {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                if currentPage != 1 {
                    Image(image2)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            }
            
            Text(title)
                .font(.custom("Roboto-Bold", size: 30))
                .foregroundColor(Color("Title"))
                .padding(.top)
            
            Text(description)
                .foregroundColor(Color("Subitems"))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer(minLength: 120)
        }
    }
}

struct PersonTileView: View {
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var person: Contact
    var setDate: Bool
    @State var date: String?
    
    var body: some View {
        HStack {

            VStack(alignment: .leading, spacing: 8) {
                
                Text(person.name)
                    .font(.custom("Roboto-Bold", size: 20))
                    .foregroundColor(Color("Items"))
                
                if setDate {
                    
                    let transaction = person.transactions!.array as! [Transaction]
                    let lastTransaction = transaction.last
                    
                    Text( date ?? "No Transactions")
                        .onReceive(timer) { (_) in
                            self.date = lastTransaction?.currentDate.timeAgoDisplay()
                        }
                        .font(.custom("Open-Sans", size: 12))
                        .foregroundColor(Color("Subitems"))
                } else {
                    Text( "No Transactions")
                        .font(.custom("Open-Sans", size: 12))
                        .foregroundColor(Color("Subitems"))
                }
            }
            
            Spacer()

            
            if setDate {
                
                let transaction = person.transactions!.array as! [Transaction]
                let amount = transaction.map{($0.amount)}.reduce(0,+) as Float
                
                Button (action: {
                    
                })  {
                    
                    Text("\(suffixNumber(number: NSNumber(value: amount)))" as String)
                            .foregroundColor((amount) >= 0 ? Color("Amount") : Color.red)
                            .font(.custom("Roboto-Bold", size: 20))
                }
            } else {
                Button (action: {
                    
                })  {
                        
                    let locale = Locale.current
                    let currencySymbol = locale.currencySymbol ?? ""
                    
                    Text("\(currencySymbol) 0")
                        .foregroundColor(Color("Amount"))
                        .font(.custom("Roboto-Bold", size: 20))
                }
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func currencyFormatting (value: Float) -> String {
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    
    return "\(formatter.string(from: NSNumber(value: value)) ?? "")"
}

var totalPages = 4
