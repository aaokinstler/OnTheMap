//
//  SelfStudentLocation.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 05.07.2021.
//

import Foundation

struct StudentLocation: Codable {
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    let createdAt: Date
    let updatedAt: Date
    let mapString: String
}
