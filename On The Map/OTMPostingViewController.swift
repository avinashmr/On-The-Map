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
    
    // States of UI
    private enum UIState {
        case initial
        case mapDone
    }
    
    
    
    // MARK: IBOutlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var locationInputTextField: UITextField!
    @IBOutlet weak var urlInputTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitURLButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mapView.delegate = self
        configureUI(.initial)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        if locationInputTextField.text!.isEmpty {
            print("Location empty")
            return
        }
        
        print(locationInputTextField.text)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationInputTextField.text!) { (results, error) in
            if (error != nil) {
                print("could not geocode")
            } else {
                self.studyLocation = results?[0]
                
                self.configureUI(.mapDone)
                
                let placemark = MKPlacemark(placemark: self.studyLocation!)
                self.mapView.showAnnotations([placemark], animated: true)
                
                
            }
        }

        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    private func configureUI(state: UIState) {
    
        switch (state) {
        case .initial:
            self.mapView.alpha = 0.2
            locationInputTextField.hidden = false
            findOnTheMapButton.hidden = false
            urlInputTextField.hidden = true
            submitURLButton.hidden = true
        case .mapDone:
            self.questionLabel.text = "Where online are you studying?"
            self.locationInputTextField.hidden = true
            self.findOnTheMapButton.hidden = true
            self.urlInputTextField.hidden = false
            self.submitURLButton.hidden = false

            UIView.animateWithDuration(2, animations: {
                self.mapView.alpha = 0.9
            })
        }
    }
    
}

extension OTMPostingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
