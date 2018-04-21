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

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}

public class Drop: NSManagedObject, MKAnnotation, Codable {
    public init(latitude: Float, longitude: Float, quantity: Int16, notes: String, entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.quantity = quantity
        self.notes = notes
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case quantity = "reportCount"
        case notes = "description"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Drop", in: managedObjectContext) else {
                fatalError("Failed to decode Drop")
        }
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            latitude: try valueContainer.decode(Float.self, forKey: CodingKeys.latitude),
            longitude: try valueContainer.decode(Float.self, forKey: CodingKeys.longitude),
            quantity: try valueContainer.decode(Int16.self, forKey: CodingKeys.quantity),
            notes: try valueContainer.decode(String.self, forKey: CodingKeys.notes),
            entity: entity,
            insertInto: nil)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(notes, forKey: .notes)
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
