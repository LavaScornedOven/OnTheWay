//
//  PinMapViewController.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 04/03/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import UIKit
import MapKit

class PinMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var studentMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentMap.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadAnnotations()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            
            // if the subtitle is not a string, we don't add button to pin
            // so the UI is a bit more intuitive
            let url = URL(string: annotation.subtitle! ?? "")
            if url != nil && (url!.scheme == "http" || url!.scheme == "https") {
                pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle!, let requestUrl = URL(string: toOpen) {
                openUrlInBrowser(request: requestUrl, completion: nil)
            }
        }
    }
    
    func reloadAnnotations() -> Void {
        var annotations = [MKAnnotation]()
        
        for student in SessionModel.students {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            annotations.append(annotation)
        }
        
        studentMap.removeAnnotations(studentMap.annotations)
        studentMap.addAnnotations(annotations)
    }
}
