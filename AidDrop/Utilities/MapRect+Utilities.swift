//
//  MapRect+Utilities.swift
//  AidDrop
//
//  Created by John Corry on 4/18/18.
//  Copyright © 2018 John Corry. All rights reserved.
//

import Foundation
import MapKit

extension MKMapRect {
    func getNECoordinate() -> CLLocationCoordinate2D {
        return self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(self), y: self.origin.y)
    }
    
    func getNWCoordinate() -> CLLocationCoordinate2D {
        return self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMinX(self), y: self.origin.y)
    }
    
    func getSECoordinate() -> CLLocationCoordinate2D {
        return self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(self), y: MKMapRectGetMaxY(self))
    }
    
    func getSWCoordinate() -> CLLocationCoordinate2D {
        return self.getCoordinateFromMapRectanglePoint(x: self.origin.x, y: MKMapRectGetMaxY(self))
    }
    
    func getCoordinateFromMapRectanglePoint (x: Double, y: Double) -> CLLocationCoordinate2D  {
        let swMapPoint = MKMapPointMake(x, y) as MKMapPoint
        return MKCoordinateForMapPoint(swMapPoint)
    }
    
    func getBoundingBox() -> [Double] {
        let bottomLeft = self.getSWCoordinate()
        let topRight = self.getNECoordinate()
        return [bottomLeft.latitude, bottomLeft.longitude, topRight.latitude, topRight.longitude]
    }
}

