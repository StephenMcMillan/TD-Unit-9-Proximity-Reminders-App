//
//  ProximityReminderError.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import Foundation

// Details all the possible errors that can occur throughout the app.
enum ProximityReminderError: Error {

    // Field Validation Errors
    case invalidReminderDescription
}

// Allows localized descriptions to be retrieved from custom error enum.
extension ProximityReminderError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .invalidReminderDescription:
            return "To create a proximity reminder, we will need to know what you want to be reminded about. Please populate the description field."
        }
    }
}
