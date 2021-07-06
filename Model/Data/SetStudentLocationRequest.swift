//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 26.06.2021.
//

import Foundation

struct SetStudentLocationRequest : Codable{

    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    let mapString: String

}
