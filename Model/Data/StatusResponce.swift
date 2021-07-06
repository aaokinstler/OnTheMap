//
//  StatusResponce.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 26.06.2021.
//

import Foundation

struct StatusResponce: Codable{
    let status: Int
    let error: String
    enum CodingKeys: String, CodingKey {
        case status
        case error 
    }
}
