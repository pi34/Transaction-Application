//
//  Project+CoreDataProperties.swift
//  Ledger
//
//  Created by Riya Manchanda on 15/05/21.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var name: String
    @NSManaged public var id: UUID?
    @NSManaged public var people: NSMutableOrderedSet

}

// MARK: Generated accessors for people
extension Project {

    @objc(insertObject:inPeopleAtIndex:)
    @NSManaged public func insertIntoPeople(_ value: Contact, at idx: Int)

    @objc(removeObjectFromPeopleAtIndex:)
    @NSManaged public func removeFromPeople(at idx: Int)

    @objc(insertPeople:atIndexes:)
    @NSManaged public func insertIntoPeople(_ values: [Contact], at indexes: NSIndexSet)

    @objc(removePeopleAtIndexes:)
    @NSManaged public func removeFromPeople(at indexes: NSIndexSet)

    @objc(replaceObjectInPeopleAtIndex:withObject:)
    @NSManaged public func replacePeople(at idx: Int, with value: Contact)

    @objc(replacePeopleAtIndexes:withPeople:)
    @NSManaged public func replacePeople(at indexes: NSIndexSet, with values: [Contact])

    @objc(addPeopleObject:)
    @NSManaged public func addToPeople(_ value: Contact)

    @objc(removePeopleObject:)
    @NSManaged public func removeFromPeople(_ value: Contact)

    @objc(addPeople:)
    @NSManaged public func addToPeople(_ values: NSOrderedSet)

    @objc(removePeople:)
    @NSManaged public func removeFromPeople(_ values: NSOrderedSet)

}

extension Project : Identifiable {

}
