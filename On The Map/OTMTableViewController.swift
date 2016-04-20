//
//  OTMTableViewController.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/15/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit

class OTMTableViewController: UITableViewController {
    
    //IBOutlets
    @IBOutlet weak var studentInformationTableView: UITableView!
    
    // View Life Cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateTableData(nil)
        
        // Watch for Refresh Button Pushes on Tab Bar Controller and update data accordingly
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableData:", name: OTMClient.Notification.refreshData, object: nil)
        
    }

    // Functions
    func updateTableData(notification: NSNotification?) {

        OTMTabBarController.sharedInstance().updateStudentInformation(self, view: view) { (success, error) in
            if success {
                performUIUpdatesOnMain({
                    self.studentInformationTableView.reloadData()
                })
            } else {
                self.displayError(error)
            }
        }
    }

    private func displayError(errorString: String?) {
        let alertView = UIAlertController(title: "Login Error", message: errorString, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }


// MARK: - TableView Functions

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "studentTableViewCell"
        let student = StudentInformation.studentInformation[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.studentInformation.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = StudentInformation.studentInformation[indexPath.row]
        
        OTMClient.sharedInstance().formatURL(student.mediaURL!, completionHandlerForURL: { (success, newURL, error) in
            if success {
                UIApplication.sharedApplication().openURL(NSURL(string: newURL!)!)
            } else {
                self.displayError(error)
            }
        })
    }



}