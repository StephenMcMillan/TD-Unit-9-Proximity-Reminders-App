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
    case missingReminderLocation
    
    // Location Errors
    case locationServicesDisabled
    case locationServicesDeniedByUser
    
    // Notification Errors
    case notificationsDeniedByUser
    
    // Core Data Errors
    case errorWhilstValidatingReminders
}

// Allows localized descriptions to be retrieved from custom error enum.
extension ProximityReminderError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .invalidReminderDescription:
            return "To create a proximity reminder, we will need to know what you want to be reminded about. Please populate the description field."
        case .missingReminderLocation:
            return "To create a proximity reminder, you will need to select a location where you would like to be reminded."
        case .locationServicesDisabled:
            return "This app requires location services is order to send you reminders when you arrive at or leave a location. Please enable location services in Settings."
        case .locationServicesDeniedByUser:
            return "This app requires location services is order to send you reminders when you arrive at or leave a location. It seems like you have denied location permissions. Please enable location services for Proximity Reminders in Settings."
        case .notificationsDeniedByUser:
            return "This app requires notification permissions is order to send you reminders when you arrive at or leave a location. It seems like you have denied notification permissions. Please enable notifications for Proximity Reminders in Settings."
        case .errorWhilstValidatingReminders:
            return "Something went wrong in the background. If this problem persists please reinstall the app or contact the developer."
        }
    }
}
