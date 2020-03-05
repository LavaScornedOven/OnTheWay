//
//  Utils.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 04/03/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import Foundation
import UIKit
import MapKit


func alert(title: String, error: Error, parent: UIViewController) {
    let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
    parent.present(alert, animated: true, completion: nil)
}

func openUrlInBrowser(request: URL, completion: ((Bool) -> Void)?) {
    if UIApplication.shared.canOpenURL(request) {
        UIApplication.shared.open(request, options: [:], completionHandler: completion)
    }
}

func mapViewForAnnotation(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.pinTintColor = .red
        pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
        pinView!.annotation = annotation
    }
    
    return pinView
}
