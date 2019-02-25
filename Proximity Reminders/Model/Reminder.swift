//
//  Reminder.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//
//

import Foundation
import MapKit
import CoreData

enum AlertType {
    case arriving
    case leaving
}

public class Reminder: NSManagedObject {}

extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var uuid: UUID // This gets set once the notification has been scheduled by the system.
    @NSManaged public var reminderDescription: String
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var alertWhenLeaving: Bool
    @NSManaged public var location: Location
    
    
    /// Creates a new reminder managed object with an associated location managed object and returns that object.
    ///
    /// - Parameters:
    ///   - description: the description or actual reminder the user created. Eg: Pick up milk.
    ///   - alertType: an enum describing whether the user wants notified on arrival or on departure
    ///   - mapItem: a MKMapItem allowing for the easy creation of a location object
    ///   - context: the managed object context into which the object should be inserted
    /// - Returns: A reference to the newly created reminder.
    class func create(withDescription description: String, alertType: AlertType, fromMapItem mapItem: MKMapItem, inContext context: NSManagedObjectContext) -> Reminder {
        
        let newReminder = Reminder(context: context)
        newReminder.reminderDescription = description
        newReminder.alertWhenLeaving = (alertType == .leaving) ? true : false
        newReminder.dateCreated = Date() as NSDate
        
        let reminderLocation = Location(context: context)
        reminderLocation.name = mapItem.name ?? "Unknown"
        reminderLocation.longitude = mapItem.placemark.coordinate.longitude
        reminderLocation.latitude = mapItem.placemark.coordinate.latitude
        
        newReminder.location = reminderLocation
        return newReminder
        // Done creating new reminder.
    }

}
