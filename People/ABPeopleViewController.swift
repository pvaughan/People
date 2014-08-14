//
//  ABPeopleViewController.swift
//  People
//
//  Created by Taras Kalapun on 13/08/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class ABPeopleViewController: UITableViewController {

    var items : [ABRecordRef] = []
    var company : String = ""
    var asPicker = false
    var delegate : CompanyPickerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.company
        
        self.tableView.rowHeight = 58
        self.tableView.registerNib(UINib(nibName: "PersonCell", bundle: nil), forCellReuseIdentifier: "PersonCell")
        
        let sepLineImg = UIImage(named: "grey_dotted_line").resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0))
        self.tableView.separatorColor = UIColor(patternImage: sepLineImg)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        if (self.asPicker) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: UIBarButtonItemStyle.Done, target: self, action: "pick")
        }
        
        //performFetchAndReload(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        performFetchAndReload(true)
    }
    
    func performFetchAndReload(reload: Bool) {
        self.items = AB.shared.recordsByCompany(self.company)
        if reload {
            self.tableView.reloadData()
        }
    }
    
    func pick() {
        var indexPath = self.tableView.indexPathForSelectedRow()
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let n = self.items.count
        var alert = UIAlertController(title: "Add \(n) records?", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel){ _ in })
        alert.addAction(UIAlertAction(title: "Add", style: .Default){ action in
            if self.delegate.respondsToSelector("companyPicker:pickedCompany:") {
                self.delegate.companyPicker!(nil, pickedCompany: self.company)
            }
            })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateCell(cell: UITableViewCell, object: ABRecordRef) {
        let pCell = cell as PersonCell
        pCell.setABPerson(ABPerson(record: object))
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        updateCell(cell, object: self.items[indexPath.row])
        
        return cell
    }
    

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let record: ABRecordRef = self.items[indexPath.row]
        var picker = ABPersonViewController()
        picker.displayedPerson = record
        picker.allowsEditing = true
        picker.shouldShowLinkedPeople = true
        self.navigationController.pushViewController(picker, animated: true)
    }

}
