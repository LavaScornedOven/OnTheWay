//
//  AddLocationViewController.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 03/03/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import CoreLocation
import UIKit

struct NewLocation {
    var mapString: String
    var mediaUrl: String
    var coordinate: CLLocationCoordinate2D
}

protocol WithNewLocation {
    func setNewLocation(newLocation: NewLocation);
}

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mapStringText: UITextField!
    @IBOutlet weak var mediaUrlText: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var newLocation: NewLocation! = nil
    var isSearching: Bool = false
    var geocoder: CLGeocoder! = nil
    var keyboardHandler: KeyboardHandler! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapStringText.delegate = self
        mediaUrlText.delegate = self
        keyboardHandler = KeyboardHandler(view: view, textFields: [mapStringText, mediaUrlText])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardHandler.subscribe()
        changeUIState(searching: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        keyboardHandler.unsubscribe()

        if geocoder != nil {
            geocoder.cancelGeocode()
            geocoder = nil
        }
    }
    
    @IBAction func cancelTouched(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        changeUIState(searching: isSearching)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func findLocationTouched(_ sender: Any) {
        geocoder = CLGeocoder()
        changeUIState(searching: true)
        
        geocoder.geocodeAddressString(mapStringText.text!) {
            (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    self.geocodeResponseHandler(coordinate: location.coordinate, error: nil)
                    return
                }
            }
                
            self.geocodeResponseHandler(coordinate: kCLLocationCoordinate2DInvalid, error: error)
        }
    }
    
    func geocodeResponseHandler(coordinate: CLLocationCoordinate2D, error: Error?) {
        changeUIState(searching: false)
        if error != nil {
            alert(title: "Geocoding Failed", error: error!, parent: self)
            return
        }
        
        newLocation = NewLocation(mapString: mapStringText.text!, mediaUrl: mediaUrlText.text!, coordinate: coordinate)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showLocation", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddLocationMapViewController {
            destination.setNewLocation(newLocation: newLocation)
        }
    }
    
    func changeUIState(searching: Bool) {
        if searching {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        mapStringText.isEnabled = !searching
        mediaUrlText.isEnabled = !searching
        
        findLocationButton.isEnabled = !searching && mapStringText.text ?? "" != "" && mediaUrlText.text ?? "" != ""
        findLocationButton.alpha = findLocationButton.isEnabled ? 1.0 : 0.5
        
        isSearching = searching
    }
}
