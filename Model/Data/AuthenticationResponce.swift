//
//  AuthenticationResponce.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 26.06.2021.
//

import Foundation

struct AuthenticationResponce : Codable {
    let account: Account
    let session: Session
}

struct Account : Codable {
    let registered: Bool
    let key: String
}

struct Session : Codable{
    let id: String
    let expiration: String
}
