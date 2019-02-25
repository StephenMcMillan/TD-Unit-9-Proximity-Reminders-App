//
//  ReminderListController.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderListController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            print("DELIVERED: \(notifications.count)")
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (request) in
            print(request)
        })
        
    }
}


