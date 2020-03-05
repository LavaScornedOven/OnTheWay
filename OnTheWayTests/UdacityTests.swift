//
//  OnTheWayTests.swift
//  OnTheWayTests
//
//  Created by Vedran Novoselac on 22/02/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import XCTest
@testable import OnTheWay

class UdacityTests: XCTestCase {

    override func setUp() {
        if UdacityCredentials.username == "" {
            XCTFail("Set up udacity credentials before running these tests")
        }
    }
    
    func testLoginWrongCredentials() {
        let expectation = XCTestExpectation(description: "Login succesfully failed :)")
        Udacity.login(username: "example@domain.com", password: "********") {
            session, error in
            
            guard let error = error else {
                XCTFail("wrong credentials should yield an error")
                return
            }
            
            if error.localizedDescription == "Account not found or invalid credentials." {
                expectation.fulfill()
                return
            }
            
            XCTFail("wrong error \(error.localizedDescription)")
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testLogin() {
        let expectation = XCTestExpectation(description: "Login succeeded")
        
        Udacity.login(username: UdacityCredentials.username, password: UdacityCredentials.password) {
            session, error in
            
            guard let _ = session else {
                XCTFail("logging in with valid credentials should yield a new session")
                return
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchStudentInformation() {
        let expectation = XCTestExpectation(description: "Got student information")

        Udacity.StudentLocation.get(limit: 1) {
            studentInformation, error in
            
            if studentInformation.count == 1 {
                expectation.fulfill()
            } else {
                XCTFail("Only one result should be returned when single result is requested")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCreateStudentInformation() {
        let expectation = XCTestExpectation(description: "Create new student information")
        
        let info = StudentInformation.new(firstName: "Charles", lastName: "Bronson", latitude: 0.1, longitude: 0.1, mapString: "Paul Kersey in Death Wish II", mediaURL: "https://youtube.com")
        Udacity.StudentLocation.post(studentInformation: info) {
            studentInfo, error in
            
            if let error = error {
                XCTFail("Posting new student information should not fail: " + error.localizedDescription)
                return
            }
            
            guard let studentInfo = studentInfo else {
                XCTFail("On success we should get the original resource updated with creation data")
                return
            }
            
            XCTAssertNotNil(studentInfo.createdAt)
            XCTAssertNotNil(studentInfo.objectId)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
