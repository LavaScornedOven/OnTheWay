//
//  StudentInformation.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 02/03/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import Foundation

public struct StudentInformation: Codable {
    var createdAt: String?
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectId: String?
    var uniqueKey: String
    var updatedAt: String?
    
    public static func new(firstName: String, lastName: String, latitude: Double, longitude: Double, mapString: String, mediaURL: String) -> StudentInformation {
        return StudentInformation(createdAt: nil, firstName: firstName, lastName: lastName, latitude: latitude, longitude: longitude, mapString: mapString, mediaURL: mediaURL, objectId: nil, uniqueKey: String(UUID().uuidString.suffix(8)), updatedAt: nil)
    }
}
