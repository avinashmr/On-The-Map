//
//  TabBarController.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/7/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addAPin: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: - IBActions
    @IBAction func addAPin(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            performUIUpdatesOnMain({
                let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("PostingViewController")
                self.presentViewController(viewController, animated: true, completion: nil)
            })

        } else {
            performUIUpdatesOnMain({
                self.displayError("No Internet Connection to add a new pin. Try again later.")
            })
        }
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(OTMClient.Notification.refreshData, object: nil)
    }

    @IBAction func logout(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            OTMClient.sharedInstance().logoutOfUdacity { (success, error) in
                if success {
                    performUIUpdatesOnMain({
                        if let presentingViewController = self.presentingViewController {
                            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            self.displayError(error)
                        }
                    })
                }
            }
        } else {
            self.displayError("No Internet Connection to properly logout.")
        }
    }
    
    // MARK: - Functions
    
    // Update Student Location is in TabBarController so both MapView and TableView can access it.
    func updateStudentInformation(viewController: UIViewController, view: UIView,
                                  completionHandlerForStudentInformation: (success: Bool, error: String?) -> Void) {
        if Reachability.isConnectedToNetwork() == true {
            OTMClient.sharedInstance().getStudentLocations({ (success, error) in
                if success {
                    completionHandlerForStudentInformation(success: true, error: nil)
                } else {
                    completionHandlerForStudentInformation(success: false, error: "Could not download Data")
                }
            })
        }
        else {
            completionHandlerForStudentInformation(success: false, error: "No Internet Connection to update data.")
        }
    }

    private func displayError(errorString: String?) {
        let alertView = UIAlertController(title: "Login Error", message: errorString, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }

    // MARK: - Shared Instance
    // This is to share the functions above with MapView and TableView
    class func sharedInstance() -> OTMTabBarController {
        struct Singleton {
            static var sharedInstance = OTMTabBarController()
        }
        return Singleton.sharedInstance
    }

}