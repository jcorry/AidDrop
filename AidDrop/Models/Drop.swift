//
//  Drop.swift
//  AidDrop
//
//  Created by John Corry on 12/13/17.
//  Copyright © 2017 John Corry. All rights reserved.
//

import MapKit
import CoreLocation

class Drop: NSObject, MKAnnotation {
    var location: CLLocation
    var coordinate: CLLocationCoordinate2D
    var aidType: AidType
    var quantity: Int?
    var timestamp: Date
    var notes: String?
    
    init(location: CLLocation, aidType: AidType, quantity: Int?) {
        self.location = location
        self.coordinate = location.coordinate
        self.aidType = aidType
        self.quantity = quantity
        self.timestamp = Date()
        
        super.init()
    }
    
    var subtitle: String? {
        return "\(aidType.description) for \(quantity!)"
    }
    
    func getDistanceInKm(from: CLLocation) -> CLLocationDistance {
        let distance = location.distance(from: from)/1000
        return CLLocationDistance(round(1000 * distance) / 1000)
    }
}

enum AidType: String {
    case food = "🍝"
    case clothing = "👕"
    case medical = "🚑"
    
    func __conversion() -> String {
        switch self {
        case .food:
            return "🍝"
        case .clothing:
            return "👕"
        case .medical:
            return "🚑"
        }
    }
    
    public var description: String {
        switch self {
        case .food:
            return "🍝"
        case .clothing:
            return "👕"
        case .medical:
            return "🚑"
        }
    }
}
