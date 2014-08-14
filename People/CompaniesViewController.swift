//
//  CompanyPickerViewController.swift
//  People
//
//  Created by Taras Kalapun on 13/08/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import UIKit

@objc protocol CompanyPickerDelegate : NSObjectProtocol {
    optional func companyPicker(picker: CompaniesViewController!, pickedCompany: NSString!)
}

class CompaniesViewController: UITableViewController {

    var delegate : CompanyPickerDelegate!
    var companies = Dictionary<String, Int>()
    var companiesNames = [String]()
    var asPicker = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Select Company"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if (asPicker) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "close")
        }

        //performFetchAndReload(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        performFetchAndReload(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performFetchAndReload(reload: Bool) {
        self.companies = AB.shared.getCompaniesWithCount()
        self.companiesNames = self.companies.keys.array.sorted { $0 < $1 }
        if reload {
            self.tableView.reloadData()
        }
    }

    func close (){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pick(company:String) {
        var indexPath = self.tableView.indexPathForSelectedRow()
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let n = self.companies[company] as Int!
        var alert = UIAlertController(title: "Add \(n) records?", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel){ _ in })
        alert.addAction(UIAlertAction(title: "Add", style: .Default){ action in
            if self.delegate.respondsToSelector("companyPicker:pickedCompany:") {
                self.delegate.companyPicker!(self, pickedCompany: company)
            }
            })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func viewPeople(company:String) {
        var vc = ABPeopleViewController()
        vc.company = company
        vc.asPicker = true
        vc.delegate = self.delegate
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func companyAtIndex(index:Int) -> String {
        return self.companiesNames[index]
    }

    func renameCompany(company:String, newName: String = "") {
        
        if (countElements(newName) == 0) {
            var alert = UIAlertController(title: company, message: "rename to:", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler({ textField in
                textField.text = company
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel){ _ in })
            alert.addAction(UIAlertAction(title: "Rename", style: .Destructive){ action in
                var tf: UITextField = alert.textFields[0] as UITextField
                self.renameCompany(company, newName: tf.text)
            })
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        AB.shared.renameCompany(company, newName: newName)
        performFetchAndReload(true)
    }
    
//    lazy var companies:[String] = {
//        return AB.shared.companies
//    }()

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.companies.count
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "reuseIdentifier")
            //cell.accessoryType = (asPicker) ? .DetailDisclosureButton : .DisclosureIndicator
            cell.accessoryType = .DisclosureIndicator
        }

        // Configure the cell...
        let company : String = self.companyAtIndex(indexPath.row)
        let n = self.companies[company] as Int!
        
        cell.textLabel.text = company
        cell.detailTextLabel.text = "\(n) record(s)"

        return cell
    }
    

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let company : String = self.companyAtIndex(indexPath.row)
        //if (asPicker) {
        //    pick(company)
        //} else {
            viewPeople(company)
        //}
    }
    
    override func tableView(tableView: UITableView!, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath!) {
        let company : String = self.companyAtIndex(indexPath.row)
        viewPeople(company)
    }
    
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    }

    
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return false
    }
    
    override func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        var renameRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Rename", handler:{action, indexpath in
            let company : String = self.companyAtIndex(indexPath.row)
            self.renameCompany(company)
        });
        
        return [renameRowAction];
    }

}
