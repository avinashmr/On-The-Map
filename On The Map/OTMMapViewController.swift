//
//  MapViewController.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/7/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit
import MapKit

class OTMMapViewController: UIViewController, MKMapViewDelegate {

    // Enums for UI
    private enum UIState {
        case initial
        case reload
        case stop
    }

    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Initial Download Data
        updateMapData(nil)

        // Watch for Refresh Button Pushes on Tab Bar Controller and update data accordingly
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMapData:", name: OTMClient.Notification.refreshData, object: nil)
    }

    // Update Map Data
    func updateMapData(notification: NSNotification?) {
        OTMTabBarController.sharedInstance().updateStudentInformation(self, view: view) { (success, error) in
            self.configureUI(.reload)
            if success {
                performUIUpdatesOnMain({
                    self.addAnnotations()

                })
            } else {
                self.displayError(error)
            }
        }
    }
    
    // Alert View
    private func displayError(errorString: String?) {
        configureUI(.stop)
        let alertView = UIAlertController(title: "Map Error", message: errorString, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}
    
    
// MARK: - Map Elements
extension OTMMapViewController {
    private func addAnnotations(){

        var annotations = [MKPointAnnotation]()

        for student in StudentInformation.studentInformation {

            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude!, longitude: student.longtitude!)
            annotation.title = student.firstName + " " + student.lastName
            annotation.subtitle = student.mediaURL

            annotations.append(annotation)
        }
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
        self.configureUI(.stop)
    }


    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "studentPin"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {

            OTMClient.sharedInstance().formatURL(((view.annotation?.subtitle)!)!, completionHandlerForURL: { (success, newURL, error) in
                if success {
                    UIApplication.sharedApplication().openURL(NSURL(string: newURL!)!)
                } else {
                    self.displayError(error)
                }
            })
        }
    }
}

// MARK: - UI Elements
extension OTMMapViewController {


    // Initialize UI depending on the states this login controller goes through.
    private func configureUI(state: UIState) {

        switch state {
        case .initial:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()

        case .reload:
            activityIndicator.hidden = false
            activityIndicator.startAnimating()

        case .stop:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        }
    }

}