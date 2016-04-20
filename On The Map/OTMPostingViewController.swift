//
//  OTMPostingViewController.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/18/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit
import MapKit

class OTMPostingViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Properties
    var studyLocation: CLPlacemark?
    var studyURL: String?
    var keyboardOnScreen = false

    // States of UI
    private enum UIState {
        case initial, done, alert
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var locationInputTextField: UITextField!
    @IBOutlet weak var urlInputTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitURLButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //MARK: View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mapView.delegate = self

        configureUI(.initial)
        
    }

    // View Options
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewController()
    }

    // MARK: - IBActions
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        if locationInputTextField.text!.isEmpty {
            displayError("Please input a location.")
            return
        } else {
            performUIUpdatesOnMain({
                self.activityIndicator.hidden = false
                self.activityIndicator.startAnimating()

                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(self.locationInputTextField.text!) { (results, error) in
                    if (error != nil) {
                        self.displayError("Could not find the location, please try again.")
                        return
                    } else {
                        self.studyLocation = results?[0]
                        self.configureUI(.done)

                        let placemark = MKPlacemark(placemark: self.studyLocation!)
                        self.mapView.showAnnotations([placemark], animated: true)
                    }
                }
            })
            
        }
    }


    @IBAction func submitStudentInformation(sender: AnyObject) {

        var student = OTMClient.sharedInstance().currentStudent
        
        if (urlInputTextField.text!.isEmpty) {
            displayError("URL is empty, try again.")
            return
        } else {
            OTMClient.sharedInstance().formatURL(urlInputTextField.text!, completionHandlerForURL: { (success, newURL, error) in
                if success {
                    student?.mediaURL = newURL
                } else {
                    self.displayError(error)
                    return
                }
            })
        }

        student?.mapString = locationInputTextField.text
        
        
        if let location = studyLocation?.location {
            student?.latitude = location.coordinate.latitude
            student?.longtitude = location.coordinate.longitude
        }
        else {
            displayError("Invalid Location.")
            return
        }
        
        OTMClient.sharedInstance().postAStudentLocation(student) { (success, error) in
            if success {
                // print("successfully posted a location")
            } else {
                self.displayError(error)
            }
        
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(OTMClient.Notification.refreshData, object: nil)
        self.dismissViewController()
    }


    private func dismissViewController() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    private func displayError(errorString: String?) {
        configureUI(.alert)
        let alertView = UIAlertController(title: "Posting Error", message: errorString, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }

    private func configureUI(state: UIState) {
    
        switch (state) {
        case .initial:
            self.mapView.alpha = 0.2
            self.mapView.zoomEnabled = true
            self.mapView.scrollEnabled = true
            self.mapView.userInteractionEnabled = true
            locationInputTextField.hidden = false
            findOnTheMapButton.hidden = false
            urlInputTextField.hidden = true
            submitURLButton.hidden = true
            urlInputTextField.delegate = self
            locationInputTextField.delegate = self
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        case .done:
            self.questionLabel.text = "Where online are you studying?"
            self.locationInputTextField.hidden = true
            self.findOnTheMapButton.hidden = true
            self.urlInputTextField.hidden = false
            self.submitURLButton.hidden = false

            UIView.animateWithDuration(2, animations: {
                self.mapView.alpha = 0.9
            })
            self.mapView.zoomEnabled = false
            self.mapView.scrollEnabled = false
            self.mapView.userInteractionEnabled = false
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        case .alert:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        }
    }
    
}

// MARK: - LoginViewController: UITextFieldDelegate

extension OTMPostingViewController: UITextFieldDelegate {

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: Show/Hide Keyboard

    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }

    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }

    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }

    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(urlInputTextField)
        resignIfFirstResponder(locationInputTextField)
    }
}


