//
//  AB.swift
//  People
//
//  Created by Taras Kalapun on 07/08/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation
import AddressBook
import UIKit

class AB {

    class var shared : AB {
    struct Static {
        static let instance : AB = AB()
        }
        return Static.instance
    }
    
    var addressBook:ABAddressBookRef = {
        return ABAddressBookCreateWithOptions(nil, nil).takeUnretainedValue()
    }()
    
    init() {
        //self.addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, nil))
    }
    
    func stringPropertyFromRecord(record: ABRecordRef, property: ABPropertyID) -> String {
        var val: NSString! = Unmanaged<CFString>.fromOpaque(ABRecordCopyValue(record, property).toOpaque()).takeUnretainedValue().__conversion()
        if (!val) {
            return ""
        }
        return val
    }
    
    func recordByRecordId(recordId:ABRecordID) -> ABRecordRef? {
        if (recordId == kABRecordInvalidID) {
            return nil
        }
//        let ab: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeUnretainedValue()
//        if ab == nil {
//            return nil
//        }
        var p: ABRecordRef? = ABAddressBookGetPersonWithRecordID(self.addressBook, recordId).takeUnretainedValue()
        return p
    }

    func recordsByCompany(company:String) -> [ABRecordRef] {
        var array :[ABRecordRef] = []
        
        let records = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeUnretainedValue() as NSArray
        for record : ABRecordRef in records {
            
            if (countElements(company) == 0) {
                array.append(record)
            } else {
                var c = self.stringPropertyFromRecord(record, property: kABPersonOrganizationProperty)
                if (c == company) {
                    array.append(record)
                }
            }
        }

        return array
    }

    func recordChangeCompany(record:ABRecordRef, newCompanyName:String) {
        ABRecordSetValue(record, kABPersonOrganizationProperty, newCompanyName, nil)

        ABAddressBookSave(self.addressBook, nil)
    }

    func renameCompany(company:String, newName: String = "") {
        if (countElements(company) == 0 || company == newName) {
            return
        }

        for record in self.recordsByCompany(company) {
            self.recordChangeCompany(record, newCompanyName: newName)
        }
    }
    
//    func recordByName(name:String) -> ABRecordRef {
        //let cname = name as CFString
        //let ppl = ABAddressBookCopyPeopleWithName(self.addressBook, cname)
        
        //return ppl.first
  //  }

    func imageForRecordId(recordId:ABRecordID) -> UIImage? {
        if (recordId == kABRecordInvalidID) {
            return nil
        }
        
        var record: ABRecordRef? = recordByRecordId(recordId)
        var image : UIImage?
        if ABPersonHasImageData(record) {
            let data = ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail).takeRetainedValue()
            image = UIImage(data: data)
        }
        return image
    }
    
    func checkAddressBookAccess(completionHandler:() -> Void) {
        switch ABAddressBookGetAuthorizationStatus() {
        case .Authorized:
            completionHandler()
            break
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(self.addressBook, {success, error in
                if success {
                    completionHandler()
                }
                else {
                    NSLog("unable to request access")
                }
            })
            break
        case .Denied, .Restricted:
            NSLog("AB access denied")
            break
        }
    }
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeRetainedValue()
        }
        return nil
    }
    
    func getCompanies() -> [String] {
        var array :[String] = []

        let records = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeUnretainedValue() as NSArray
        for record : ABRecordRef in records {
            var company = self.stringPropertyFromRecord(record, property: kABPersonOrganizationProperty)
            if (countElements(company) > 0 && !contains(array, company)) {
                array.append(company)
            }
        }

        return array
    }
    
    func getCompaniesWithCount() -> Dictionary<String, Int> {
        var dict = Dictionary<String, Int>()
        
        let records = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeUnretainedValue() as NSArray
        for record : ABRecordRef in records {
            var company = self.stringPropertyFromRecord(record, property: kABPersonOrganizationProperty)
            if countElements(company) > 0 {
                if dict.indexForKey(company) == nil {
                    dict[company] = 1
                } else {
                    dict[company] = dict[company]! + 1
                }
            }
        }
        
        return dict
    }
}