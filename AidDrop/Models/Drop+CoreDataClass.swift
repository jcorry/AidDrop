//
//  Drop+CoreDataClass.swift
//  AidDrop
//
//  Created by John Corry on 4/9/18.
//  Copyright © 2018 John Corry. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation
import MapKit


public class Drop: NSManagedObject, MKAnnotation {
    public init(latitude: Float, longitude: Float, quantity: Int16, notes: String, entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.quantity = quantity
        self.notes = notes
    }
    
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D.init(
                latitude: CLLocationDegrees(self.latitude),
                longitude: CLLocationDegrees(self.longitude)
            )
        }
    }
    
    public var subtitle: String? {
        return "Aid for \(quantity) recipients."
    }
    
    func getDistanceInKm(from: CLLocation) -> CLLocationDistance {
        let locationFromCoordinates = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = locationFromCoordinates.distance(from: from)/1000
        return CLLocationDistance(round(1000 * distance) / 1000)
    }
}
