//
//  PeopleViewController.swift
//  People
//
//  Created by Taras Kalapun on 06/08/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import UIKit
import CoreData
import AddressBook
import AddressBookUI

class PeopleViewController: UITableViewController, NSFetchedResultsControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABNewPersonViewControllerDelegate, ABPersonViewControllerDelegate, CompanyPickerDelegate {
    
    var selectedPerson:Person?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "PersonCell", bundle: nil), forCellReuseIdentifier: "PersonCell")

        let sepLineImg = UIImage(named: "grey_dotted_line").resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0))
        self.tableView.separatorColor = UIColor(patternImage: sepLineImg)
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addAction:")

//        self.navigationItem.leftBarButtonItems = [
//            UIBarButtonItem(title: "i", style: .Plain, target: self, action: "infoAction:"),
//            
//        ]

        

        //AB.shared.checkAddressBookAccess({
            performFetchAndReload(false)
        //})
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (self.selectedPerson != nil) {
            self.selectedPerson?.updateFromAB()
            self.selectedPerson = nil
        }
        performFetchAndReload(true)
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        var fetch: NSFetchRequest = NSFetchRequest(entityName: "Person")
        fetch.sortDescriptors = [
            NSSortDescriptor(key: "company", ascending: true),
            NSSortDescriptor(key: "department", ascending: true),
            NSSortDescriptor(key: "fullName", ascending: true)]
        
        var frc: NSFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: DB.shared.moc,
            sectionNameKeyPath: "company",
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    func performFetchAndReload(reload: Bool) {
        var moc = fetchedResultsController.managedObjectContext
        
        moc.performBlockAndWait {
            var error: NSErrorPointer = nil
            if !self.fetchedResultsController.performFetch(error) {
                println("\(error)")
            }
            
            if reload {
                self.tableView.reloadData()
            }
        }
    }
    
    func updateCell(cell: UITableViewCell, object: Person) {
        let pCell = cell as PersonCell
        pCell.setPerson(object)
    }

    func refresh() {
        for person:Person in self.fetchedResultsController.fetchedObjects as [Person] {
            person.updateFromAB()
        }
        self.refreshControl.endRefreshing()
    }

    // MARK: - Actions
    @IBAction func infoAction(sender: AnyObject) {
    }
    
    @IBAction func addAction(sender: AnyObject) {
        var alert = UIAlertController(title: "Add new Person", message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel){ _ in })
        alert.addAction(UIAlertAction(title: "Pick", style: .Default){ action in
            self.showPersonPicker()
            })
        alert.addAction(UIAlertAction(title: "Pick by company", style: .Default){ action in
            self.showCompanyPicker()
            })
        alert.addAction(UIAlertAction(title: "Create new", style: .Default){ action in
            self.showCreateNewPersonController()
            })
        

        AB.shared.checkAddressBookAccess({
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    func showPersonPicker() {
        let picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)
    }

    func showCompanyPicker() {
        let picker = CompaniesViewController()
        picker.delegate = self
        picker.asPicker = true
        let pickerNC = UINavigationController(rootViewController: picker)
        presentViewController(pickerNC, animated: true, completion: nil)
    }

    func showCreateNewPersonController() {
        var picker = ABNewPersonViewController()
        picker.newPersonViewDelegate = self
        self.navigationController.pushViewController(picker, animated: true)
    }

    // MARK: - peoplePickerDelegate
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
        //AB.shared.checkAddressBookAccess({
            Person.createOrUpdateWithABRecord(person)
        //    return
        //})
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return fetchedResultsController.sections.count
    }

    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        let sectionInfo = fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        var item = fetchedResultsController.objectAtIndexPath(indexPath) as Person
        updateCell(cell, object: item)

        return cell
    }
    

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        var person = fetchedResultsController.objectAtIndexPath(indexPath) as Person

        let record: ABRecordRef? = AB.shared.recordByRecordId(person.abRecordId)
        if (record != nil) {
            self.selectedPerson = person
            var picker = ABPersonViewController()
            picker.personViewDelegate = self
            picker.displayedPerson = record
            picker.allowsEditing = true
            picker.shouldShowLinkedPeople = true
            self.navigationController.pushViewController(picker, animated: true)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }

    override func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        var moreRowAction = UITableViewRowAction(style: .Default, title: "More", handler:{action, indexpath in
                println("MORE•ACTION");
            });
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
                let item = self.fetchedResultsController.objectAtIndexPath(indexPath) as Person
                DB.shared.deleteObject(item)
            });
        
        return [deleteRowAction, moreRowAction];
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            let item = fetchedResultsController.objectAtIndexPath(indexPath) as Person
            DB.shared.deleteObject(item)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return false
    }
    
    // MARK: NSFetchedResultsController
    
    func controllerWillChangeContent(controller: NSFetchedResultsController!) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeSection sectionInfo: NSFetchedResultsSectionInfo!, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if type == .Insert {
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        }
        else if type == .Delete {
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if (cell != nil && anObject != nil) {
                updateCell(cell, object: anObject as Person)
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            println("unhandled didChangeObject update type \(type)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.endUpdates()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func personViewController(personViewController: ABPersonViewController!, shouldPerformDefaultActionForPerson person: ABRecordRef!, property: ABPropertyID, identifier: ABMultiValueIdentifier) -> Bool {

        

        return true
    }

    func newPersonViewController(newPersonView: ABNewPersonViewController!, didCompleteWithNewPerson person: ABRecordRef!) {
        if (person != nil) {
            Person.createOrUpdateWithABRecord(person)
        }
        self.navigationController.popViewControllerAnimated(true)
    }

    func companyPicker(picker: CompaniesViewController!, pickedCompany: NSString!) {
        NSLog("Selected company: %@", pickedCompany)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        for record in AB.shared.recordsByCompany(pickedCompany) {
            Person.createOrUpdateWithABRecord(record)
        }
    }

}
