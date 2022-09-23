//
//  Transaction+CoreDataProperties.swift
//  Ledger
//
//  Created by Riya Manchanda on 13/05/21.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Float
    @NSManaged public var date: Date
    @NSManaged public var currentDate: Date
    @NSManaged public var id: UUID?
    @NSManaged public var title: String
    @NSManaged public var person: Contact

}

extension Transaction : Identifiable {

}
