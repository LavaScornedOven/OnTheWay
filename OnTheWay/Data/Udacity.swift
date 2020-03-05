//
//  UdacityClient.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 22/02/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import Foundation
import UIKit

public struct SessionData: Codable {
    public struct Account: Codable {
        var registered: Bool
        var key: String
    }
    
    public struct Session: Codable {
        var id: String
        var expiration: String
    }
    
    var account: Account
    var session: Session
}

public struct AccountInfo: Codable {
    var firstName: String
    var lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

public class Udacity {
    static let BASE_URL = URL(string: "https://onthemap-api.udacity.com/v1/")!
    
    public struct StatusResponse: Codable {
        var status: Int
        var error: String
    }
    
    public struct CodeResponse: Codable {
        var code: Int
        var error: String
    }
    
    public class Session {
        static let RESOURCE_URL = Udacity.BASE_URL.appendingPathComponent("session")
        
        public class Post {
            struct Request: Codable {
                struct Credentials: Codable {
                    var username: String
                    var password: String
                }
                
                var udacity: Credentials
                
                init(username: String, password: String) {
                    self.udacity = Credentials(username: username, password: password)
                }
            }
            
            typealias Response = SessionData
        }
        
        public class func post(username: String, password: String, completion: @escaping (SessionData?, Error?) -> Void) {
            let loginRequest = Post.Request(username: username, password: password)
            
            var request = URLRequest(url: Session.RESOURCE_URL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // encoding a JSON body from a string, can also use a Codable struct
            request.httpBody = try! JSONEncoder().encode(loginRequest)
            
            let complete = {
                sessionData, error in
                DispatchQueue.main.async {
                    completion(sessionData, error)
                }
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    complete(nil, error)
                    return
                }
                
                guard let data = data else {
                    complete(nil, error)
                    return
                }
                
                let range = 5..<data.count
                let newData = data.subdata(in: range) /* subset response data! */
                
                do {
                    let response = try JSONDecoder().decode(SessionData.self, from: newData)
                    complete(response, nil)
                } catch {
                    do {
                        let errorResponse = try JSONDecoder().decode(StatusResponse.self, from: newData)
                        complete(nil, errorResponse)
                    } catch {
                        complete(nil, error)
                    }
                }
            }.resume()
        }
        
        public class func delete(completion: ((Bool, Error?) -> Void)?) -> URLSessionTask {
            var request = URLRequest(url: RESOURCE_URL)
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            
            let complete = {
                (success: Bool, error: Error?) in
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion(success, error)
                    }
                }
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    complete(false, error)
                    return
                }
                
                let range = 5..<data!.count
                let newData = data?.subdata(in: range) /* subset response data! */
                print(String(data: newData!, encoding: .utf8)!)
                
                complete(true, nil)
            }
            
            task.resume()
            return task
        }
    }
    
    public class Signup {
        static let REQUEST_URL = URL(string: "https://auth.udacity.com/sign-up")!
        
        class func openInBrowser(completion: ((Bool) -> Void)?) {
            openUrlInBrowser(request: REQUEST_URL, completion: completion)
        }
    }
    
    public class Users {
        static let RESOURCE_URL = Udacity.BASE_URL.appendingPathComponent("users")
        
        public class Get {
            typealias Response = AccountInfo
        }
        
        public class func get(userId: String, completion: @escaping (AccountInfo?, Error?) -> Void) {
            let complete = {
                accountInfo, error in
                DispatchQueue.main.async {
                    completion(accountInfo, error)
                }
            }
            
            let request = URLRequest(url: RESOURCE_URL.appendingPathComponent(userId))
            URLSession.shared.dataTask(with: request) {
                data, response, error in
                if error != nil { // Handle error...
                    complete(nil, error!)
                    
                }
                
                guard let data = data else {
                    complete(nil, error)
                    return
                }
                
                let range = 5..<data.count
                let newData = data.subdata(in: range) /* subset response data! */
                
                do {
                    let accountInfo = try JSONDecoder().decode(Get.Response.self, from: newData)
                    complete(accountInfo, nil)
                } catch {
                    do {
                        let errorResponse = try JSONDecoder().decode(StatusResponse.self, from: newData)
                        complete(nil, errorResponse)
                    } catch {
                        complete(nil, error)
                    }
                }
            }.resume()
        }
    }
    
    public class StudentLocation {
        static var RESOURCE_URL: URL {
            return Udacity.BASE_URL.appendingPathComponent("StudentLocation")
        }
        
        public class Get {
            struct Response: Codable {
                var results: [StudentInformation]
            }
        }
        
        @discardableResult public class func get(limit: Int, completion: @escaping ([StudentInformation], Error?) -> Void) -> URLSessionTask {
            var url = URLComponents(url: RESOURCE_URL, resolvingAgainstBaseURL: false)!
            url.queryItems = [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "order", value: "-updatedAt")
            ]
            
            let complete = { information, error in
                DispatchQueue.main.async {
                    completion(information, error)
                }
            }
            
            let task = URLSession.shared.dataTask(with: url.url!) {
                data, response, requestError in
                
                if let requestError = requestError {
                    complete([], requestError)
                    return
                }
                
                guard let data = data else {
                    complete([], requestError)
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(Get.Response.self, from: data)
                    complete(response.results, nil)
                } catch {
                    do {
                        let errorResponse = try JSONDecoder().decode(CodeResponse.self, from: data)
                        complete([], errorResponse)
                    } catch {
                        complete([], error)
                    }
                }
            }
            
            task.resume()
            return task
        }
        
        public class Post {
            struct Response: Codable {
                var createdAt: String
                var objectId: String
            }
        }
        
        @discardableResult public class func post(studentInformation: StudentInformation, completion: @escaping (StudentInformation?, Error?) -> Void) -> URLSessionTask {
            var request =  URLRequest(url: RESOURCE_URL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode(studentInformation)
            
            let complete = { studentInformation, error in
                DispatchQueue.main.async {
                    completion(studentInformation, error)
                }
            }
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, requestError in
                
                if let requestError = requestError {
                    complete(nil, requestError)
                    return
                }
                
                guard let data = data else {
                    complete(nil, requestError)
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(Post.Response.self, from: data)
                    var responseInfo = studentInformation
                    responseInfo.createdAt = response.createdAt
                    responseInfo.objectId = response.objectId
                    complete(responseInfo, nil)
                    
                } catch {
                    do {
                        let errorResponse = try JSONDecoder().decode(CodeResponse.self, from: data)
                        complete(nil, errorResponse)
                    } catch {
                        complete(nil, error)
                    }
                }
            }
            
            task.resume()
            return task
        }
    }
    
    public class func login(username: String, password: String, completion: @escaping (SessionData?, Error?) -> Void) {
        Session.post(username: username, password: password, completion: completion)
    }
    
    public class func logout(completion: ((Bool, Error?) -> Void)?) -> URLSessionTask {
        return Session.delete(completion: completion)
    }
}

extension Udacity.StatusResponse: LocalizedError {
    public var errorDescription: String? {
        return self.error
    }
}

extension Udacity.CodeResponse: LocalizedError {
    public var errorDescription: String? {
        return self.error
    }
}
