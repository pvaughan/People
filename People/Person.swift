//
//  Person.swift
//  People
//
//  Created by Taras Kalapun on 06/08/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation
import CoreData
import AddressBook
import UIKit

class Person: NSManagedObject {

    @NSManaged var abRecordId: Int32
    @NSManaged var fullName: String
    @NSManaged var company: String
    @NSManaged var department: String
    @NSManaged var jobTitle: String
    @NSManaged var imageData: NSData
        
    func updateFromAB() {
        var record : ABRecordRef? = AB.shared.recordByRecordId(self.abRecordId)
        if (record != nil) {
            self.updateFromRecord(record!)
        }
    }

    func updateFromRecord(record: ABRecordRef) {

        var recordId = ABRecordGetRecordID(record)

        if recordId != kABRecordInvalidID {
            self.abRecordId = recordId
        }
        
        var name : String = ABRecordCopyCompositeName(record).takeRetainedValue() as NSString
        self.fullName = name
        
        self.jobTitle = AB.shared.stringPropertyFromRecord(record, property: kABPersonJobTitleProperty)
        self.company = AB.shared.stringPropertyFromRecord(record, property: kABPersonOrganizationProperty)
        self.department = AB.shared.stringPropertyFromRecord(record, property: kABPersonDepartmentProperty)

        if ABPersonHasImageData(record) {
            let data = ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail).takeRetainedValue()
            self.imageData = data
        }

        DB.shared.save()
    }

    class func createOrUpdateWithABRecord(record: ABRecordRef) -> Person {
        
        var recordId = ABRecordGetRecordID(record)
        
        var fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.fetchLimit = 1
        
        if recordId == kABRecordInvalidID {
            var name : String = ABRecordCopyCompositeName(record).takeRetainedValue() as NSString
            fetchRequest.predicate = NSPredicate(format: "fullName = %@", name)
        } else {
            fetchRequest.predicate = NSPredicate(format: "abRecordId = %i", recordId)
        }
        
        var results = DB.shared.moc.executeFetchRequest(fetchRequest, error: nil)
        
        var obj : Person!
        
        if results.count > 0 {
            obj = results.first as Person
        } else {
            obj = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: DB.shared.moc) as Person
        }

        obj.updateFromRecord(record)
        
        return obj
    }

    func abImageData() -> NSData? {
        var record : ABRecordRef? = AB.shared.recordByRecordId(self.abRecordId)
        if (record != nil && ABPersonHasImageData(record)) {
            let data = ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail).takeRetainedValue()
            return data
        }
        return nil
    }


    lazy var image: UIImage = {
        var img = UIImage(data:self.imageData)
        return (img != nil ? img : UIImage(named: "placeholder_person"))
        }()
    
    lazy var title: String = {
        return self.fullName
        }()
    
    lazy var subtitle: String = {
        var s = ""
        //if (person.abRecordId > 0) {
        //    s += "(\(person.abRecordId)) "
        //}
        if (!self.department.isEmpty) {
            s += "\(self.department) / "
        }
        s += self.jobTitle
        return s
    }()
}
