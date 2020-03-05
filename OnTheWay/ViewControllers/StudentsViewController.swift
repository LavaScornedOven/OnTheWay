//
//  StudentsViewController.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 02/03/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import UIKit

class StudentsViewController: UITabBarController {

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    var currentNetworkTask: URLSessionTask? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStudentLocations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // by cancelling retrieval, we are preventing
        // any possible data races that might come
        // from add location flow
        cancelStudentLocationRetrieval()
    }
    
    @IBAction func refreshTouched(_ sender: Any) {
        getStudentLocations()
    }
    
    @IBAction func logoutTouched(_ sender: Any) {
        cancelStudentLocationRetrieval()
        SessionModel.logout()
        
        navigationController!.popViewController(animated: true)
    }
    
    func cancelStudentLocationRetrieval() {
        currentNetworkTask?.cancel()
        currentNetworkTask = nil
    }
    
    func getStudentLocations() {
        refreshButton.isEnabled = false
        Udacity.StudentLocation.get(limit: 100, completion: updateStudentLocations)
    }
    
    func updateStudentLocations(studentInfo: [StudentInformation], error: Error?) {
        defer { refreshButton.isEnabled = true }
        
        if error != nil {
            alert(title: "Data Retrieval Error", error: error!, parent: self)
            return
        } else {
            SessionModel.students = studentInfo
        }
        
        if let vc = selectedViewController as? PinTableViewController {
            vc.tableView.reloadData()
        } else if let vc = selectedViewController as? PinMapViewController {
            vc.reloadAnnotations()
        }
    }
}
