//
//  ReminderListController.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ReminderListController: UITableViewController {

    // MARK: Interface Builder Outlets
    @IBOutlet weak var whenArrivingLabel: UILabel!
    @IBOutlet weak var whenDepartingLabel: UILabel!
    
    static let reuseIdentifier = "ReminderCell"
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
        let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        let dateSortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        fetchRequest.sortDescriptors = [dateSortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.sharedManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            showErrorAlert(for: error)
        }
    }
    
    // MARK: Table View Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(fetchedResultsController.fetchedObjects?.count)
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.reuseIdentifier, for: indexPath) as! ReminderCell
        
        let reminderForCurrentRow = fetchedResultsController.object(at: indexPath)
        
        cell.reminderDescriptionLabel.text = reminderForCurrentRow.reminderDescription
        
        if reminderForCurrentRow.alertWhenLeaving {
            cell.reminderDetailLabel.text = "When Leaving \(reminderForCurrentRow.location.name)"
        } else {
            cell.reminderDetailLabel.text = "When Arriving at \(reminderForCurrentRow.location.name)"
        }
        
        return cell
    }
}


