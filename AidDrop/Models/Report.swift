//
//  Report.swift
//  AidDrop
//
//  Created by John Corry on 4/20/18.
//  Copyright © 2018 John Corry. All rights reserved.
//

import Foundation

struct Report: Codable {
    
    let latitude: Float64?
    let longitude: Float64?
    let description: String?
    let recipients: Int?
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case description
        case recipients = "recipientsCount"
    }
}
