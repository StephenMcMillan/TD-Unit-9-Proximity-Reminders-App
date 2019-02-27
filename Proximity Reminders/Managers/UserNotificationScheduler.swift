//
//  UserNotificationScheduler.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 25/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import Foundation
import UserNotifications
import MapKit

enum SchedulingResult {
    case success
    case failed(Error)
}

protocol UserNotificationScheduler {}

extension UserNotificationScheduler {
    // MARK: Methods to make it easy to request permission for notifications.
    func requestNotificationPermissions(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: completion)
    }
    
    // Gets the more general authorization status
    func getNotificationAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            completion(notificationSettings.authorizationStatus)
        }
    }
    
    // MARK: Default Implementations for notification scheduling
    func scheduleLocationNotification(forReminder reminder: Reminder, completion: @escaping (SchedulingResult) -> Void) {
        let notificationContent = UNMutableNotificationContent()
        let uuid = UUID()
                
        // Assemble the content of the notification. Example title: Now Arriving at George Best Belfast City Airport
        let titlePrefix = (reminder.alertWhenLeaving) ? "Now Leaving " : "Now Arriving at "
        notificationContent.title = titlePrefix + reminder.location.name
        notificationContent.body = reminder.reminderDescription
        notificationContent.sound = UNNotificationSound.default
        
        // Notification Delivery Conditions
        // Creates a circular region with 50m radius around a specific point the user defined previously
        let center = CLLocationCoordinate2D(latitude: reminder.location.latitude, longitude: reminder.location.longitude)
        let region = CLCircularRegion(center: center, radius: 50.0, identifier: uuid.uuidString) // Same ident causing bug?
        
        region.notifyOnExit = reminder.alertWhenLeaving
        region.notifyOnEntry = !reminder.alertWhenLeaving
        
        let notificationTrigger = UNLocationNotificationTrigger(region: region, repeats: reminder.repeats)
        
        // TODO: add the uuid to the completion to core data can save the UUID
        // UUID allows the notification to be uniquely identified at a later point and unscheduled
        let notificationRequest = UNNotificationRequest(identifier: uuid.uuidString, content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                completion(.failed(error))
            } else {
                reminder.uuid = uuid
                completion(.success)
            }
        }
    }
    
    func unscheduleLocationNotification(forIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

