//
//  ABPerson.swift
//  People
//
//  Created by Taras Kalapun on 13/08/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation
import AddressBook
import UIKit

class ABPerson {
    
    var abRecordId: Int32 = kABRecordInvalidID
    var fullName: String
    var company: String
    var department: String
    var jobTitle: String
    var imageData: NSData?

    init(record: ABRecordRef) {
        
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