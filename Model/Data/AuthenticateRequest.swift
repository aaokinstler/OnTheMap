//
//  AuthenticateRequest.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 26.06.2021.
//

import Foundation

struct AuthenticateRequest: Codable {
    let udacity: Udacity
}

struct Udacity: Codable {
    let username: String
    let password: String
}
