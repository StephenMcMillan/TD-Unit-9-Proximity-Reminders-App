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
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.sharedManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: Setup Code
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            for request in requests {
                print("REQUEST: \(request)")
            }
        }
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
            configureStats()
        } catch {
            showErrorAlert(for: error)
        }
    }
    
    func configureStats() {
        var onArrivalCount: Int = 0
        var onLeavingCount: Int = 0
            
        self.fetchedResultsController.fetchedObjects?.forEach({ (reminder) in
            if reminder.alertWhenLeaving {
                onLeavingCount += 1
            } else {
                onArrivalCount += 1
            }
        })
        self.whenArrivingLabel.text = "\(onArrivalCount)"
        self.whenDepartingLabel.text = "\(onLeavingCount)"
    }
    
    // MARK: Table View Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    // MARK: Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "ShowReminderDetail", let selectedTableViewIndex = tableView.indexPathForSelectedRow {
            // These casts are forced given that execution can't continue beyond this point if we don't have a detail view.
            let reminderDetailController = segue.destination as! ReminderDetailController
            
            reminderDetailController.reminder = fetchedResultsController.object(at: selectedTableViewIndex)
        }
    }
}

extension ReminderListController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // Called when an object is modified by the user or deleted etc.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath] , with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move: // Not required.
            break
        }
        
        configureStats()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}


