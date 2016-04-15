//
//  OTMTableViewController.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/15/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit

class OTMTableViewController: UITableViewController {
    
    var studentInformation: [StudentInformation] = [StudentInformation]()
    
    @IBOutlet weak var studentInformationTableView: UITableView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        OTMClient.sharedInstance().getStudentLocations(100) { (success, students, error) in
            if success {
                if let studentInformation = students {
                    self.studentInformation = students!
                    performUIUpdatesOnMain({ 
                        self.studentInformationTableView.reloadData()
                    })
                }
            } else {
                //error
            }
        }
    }
    
    

    

    
    

// MARK: - TableView Functions

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "studentTableViewCell"
        let student = studentInformation[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel!.text = student.firstName + " " + student.lastName
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentInformation.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = studentInformation[indexPath.row]
        
        if let url = NSURL(string: student.mediaURL!) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                print("error")
            }
        }
    }

    
}