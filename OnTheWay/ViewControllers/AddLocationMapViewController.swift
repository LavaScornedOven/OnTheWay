//
//  AddLocationMapViewController.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 03/03/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import UIKit
import MapKit

class AddLocationMapViewController: UIViewController, WithNewLocation, MKMapViewDelegate {
    @IBOutlet weak var newLocationMap: MKMapView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var newLocation: NewLocation! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newLocationMap.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        newLocationMap.removeAnnotations(newLocationMap.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        annotation.title = newLocation.mapString
        
        newLocationMap.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: newLocation.coordinate, span: newLocationMap.region.span)
        newLocationMap.setRegion(region, animated: animated)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func setNewLocation(newLocation nl: NewLocation) {
        newLocation = nl
    }
    
    @IBAction func finishTouched(_ sender: Any) {
        changeUIState(creatingNew: true)
                
        let studentInfo = StudentInformation.new(
            firstName: SessionModel.accountInfo?.firstName ?? "<first-name>",
            lastName: SessionModel.accountInfo?.lastName ?? "<last-name>",
            latitude: newLocation.coordinate.latitude,
            longitude: newLocation.coordinate.longitude,
            mapString: newLocation.mapString,
            mediaURL: newLocation.mediaUrl
        )
        
        // Here local copy of the latest query result is updated
        // instead of syncing with the server again. This allows
        // user to have its own latest pins in focus, instead of
        // mixing local work with other students. Only on explicit
        // request from the user (refresh button), will the app
        // pull latest pins from the server.    
        SessionModel.students.insert(studentInfo, at: 0)
        
        Udacity.StudentLocation.post(studentInformation: studentInfo) {
            studentInfo, error in
            self.changeUIState(creatingNew: false)
            
            if error != nil {
                alert(title: "Saving Location Failed", error: error!, parent: self)
                return
            }
            
            SessionModel.students.append(studentInfo!)
            
            self.navigationController!.dismiss(animated: true, completion: nil)
        }
    }
    
    func changeUIState(creatingNew: Bool) {
        findButton.isEnabled = !creatingNew
        
        if creatingNew {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
