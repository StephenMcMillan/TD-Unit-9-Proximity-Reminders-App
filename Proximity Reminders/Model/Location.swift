//
//  Location.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//
//

import Foundation
import MapKit
import CoreData

public class Location: NSManagedObject {}

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var name: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var reminder: Reminder
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    func update(using mapItem: MKMapItem?) {
        
        guard let mapItem = mapItem else { return }
        
        self.name = mapItem.name ?? "Unkown"
        self.latitude = mapItem.placemark.coordinate.latitude
        self.longitude = mapItem.placemark.coordinate.longitude
    }
}
