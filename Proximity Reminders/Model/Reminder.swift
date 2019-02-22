//
//  Reminder.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//
//

import Foundation
import CoreData

public class Reminder: NSManagedObject {}

extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var reminderDescription: String?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var alertWhenLeaving: Bool
    @NSManaged public var location: Location?

}
