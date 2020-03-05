//
//  RuntimeModel.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 24/02/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import Foundation

class SessionModel {
    
    static var session: SessionData?
    static var accountInfo: AccountInfo?
    static var students: [StudentInformation] = []
    static var currentLogoutTask: URLSessionTask? = nil
    
    public static func clear() {
        session = nil
        students = []
    }
    
    public static func login(username: String, password: String, completion: @escaping (SessionData?, Error?) -> Void) {
        if currentLogoutTask != nil {
            currentLogoutTask!.cancel()
            currentLogoutTask = nil
        }
        
        Udacity.login(username: username, password: password) {
            sessionData, error in
            
            if error != nil {
                completion(nil, error!)
                return
            }
            
            Udacity.Users.get(userId: sessionData?.account.key ?? "") {
                accountInfo, error in
                
                if error != nil {
                    completion(sessionData, nil)
                    return
                }
                
                SessionModel.accountInfo = accountInfo
                completion(sessionData, nil)
            }
        }
    }
    
    public static func logout() {
        currentLogoutTask = Udacity.logout() {
            success, error in
            if error != nil {
                print("Logout error: \(error!)")
            }
        }
        clear()
    }
}
