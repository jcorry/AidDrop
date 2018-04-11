//
//  Drop+CoreDataProperties.swift
//  AidDrop
//
//  Created by John Corry on 4/9/18.
//  Copyright © 2018 John Corry. All rights reserved.
//
//

import Foundation
import CoreData


extension Drop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drop> {
        return NSFetchRequest<Drop>(entityName: "Drop")
    }

    @NSManaged public var created: NSDate?
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var notes: String?
    @NSManaged public var quantity: Int16

}
