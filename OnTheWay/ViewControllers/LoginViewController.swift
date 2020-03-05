//
//  ViewController.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 22/02/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var usernameView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var keyboardHandler: KeyboardHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameView.delegate = self
        passwordView.delegate = self
        
        keyboardHandler = KeyboardHandler(view: view, textFields: [usernameView, passwordView])
        
        changeUIState(loggingIn: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardHandler.subscribe()
        
        navigationController!.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        changeUIState(loggingIn: false)
        passwordView.text = nil
        
        keyboardHandler.unsubscribe()
        
        navigationController!.isNavigationBarHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        changeUIState(loggingIn: false)
    }
    
    @IBAction func loginTouched(_ sender: Any) {
        changeUIState(loggingIn: true)
        
        SessionModel.login(username: usernameView.text ?? "", password: passwordView.text ?? "") {
            sessionData, error in
            
            self.changeUIState(loggingIn: false)
            
            guard let sessionData = sessionData else {
                alert(title: "Login Error", error: error!, parent: self)
                return
            }
            
            SessionModel.session = sessionData
            
            self.performSegue(withIdentifier: "loginSuccessful", sender: nil)
        }
    }
    
    @IBAction func signupTouched(_ sender: Any) {
        Udacity.Signup.openInBrowser(completion: nil)
    }
    
    func changeUIState(loggingIn: Bool) {
        usernameView.isEnabled = !loggingIn
        passwordView.isEnabled = !loggingIn
        
        loginButton.isEnabled = !loggingIn
        
        loginButton.isEnabled = !loggingIn && usernameView.text ?? "" != "" && passwordView.text ?? "" != ""
        loginButton.alpha = loginButton.isEnabled ? 1.0 : 0.5
        
        signupButton.isEnabled = !loggingIn
        loggingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}
