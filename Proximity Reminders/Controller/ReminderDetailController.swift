//
//  ReminderDetailController.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//
//  ReminderDetailController can be accessed by either:
//      - Tapping on a table view cell to reveal details about that specific reminder or;
//      - Tapping on the add button on the table view to add a new reminder.

import UIKit
import MapKit
import UserNotifications

class ReminderDetailController: UITableViewController {

    // MARK: Interface Builder Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var alertTypeSegment: UISegmentedControl!
    @IBOutlet weak var repeatToggle: UISwitch!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var deleteReminderButton: UIButton!
    
    // MARK: Properties
    /// This reminder property is nil if the user is creating a new entry.
    var reminder: Reminder?
    
    var mapItem: MKMapItem? {
        didSet {
            configureMapView(with: mapItem)
            reminder?.location.update(using: mapItem)
        }
    }
    
    var movingForwards: Bool = false
    
    // MARK: View Set-up / Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        checkAuthorization()
        
        // Specific setup code that depends on whether a reminder has been set or not
        if let reminder = reminder {
            configure(with: reminder)
        } else {
            confiureForNewEntry()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        movingForwards = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard reminder != nil && !movingForwards else { return }
        updateExistingReminder()
    }
    
    // Takes an existing reminder and sets-up the view to display the details of that reminder
    func configure(with reminder: Reminder) {
        configureMapView(withName: reminder.location.name, andCoordinate: reminder.location.coordinate)
        descriptionTextView.text = reminder.reminderDescription
        alertTypeSegment.selectedSegmentIndex = (reminder.alertWhenLeaving) ? 1 : 0
        repeatToggle.isOn = reminder.repeats
        locationButton.setTitle(reminder.location.name, for: .normal)
        deleteReminderButton.isHidden = false
    }
    
    func confiureForNewEntry() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ReminderDetailController.saveReminder))
        navigationItem.rightBarButtonItem = rightBarButton
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ReminderDetailController.dismissNewReminder))
        navigationItem.leftBarButtonItem = leftBarButton
        
        deleteReminderButton.isHidden = true
    }
    
    // MARK: Location Related Logic
    @IBAction func selectLocation() {
        movingForwards = true
        showLocationPicker()
    }
    
    func showLocationPicker() {
        let locationSearchController = LocationSearchController()
        locationSearchController.delegate = self
        let locationSearchNavController = UINavigationController(rootViewController: locationSearchController)
        present(locationSearchNavController, animated: true, completion: nil)
    }
    
    // MARK: Map View Logic
    func configureMapView(with mapItem: MKMapItem?) {
        guard let mapItem = mapItem else { return }
        configureMapView(withName: mapItem.name, andCoordinate: mapItem.placemark.coordinate)
    }
    
    // Splitting this logic into two functions means this second function can be used to set-up the view from a Location Managed Object if the user is viewing an existing entry.
    func configureMapView(withName name: String?, andCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.dropPin(withName: name, at: coordinate)
        mapView.drawCirlce(withCenter: coordinate)
        mapView.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200), animated: true)
    }
    
    // MARK: Save a New Reminder
    /// Validates the input fields then attempts to schedule a reminder and subsequently save a reminder to core data
    @objc func saveReminder() {
        
        // 1. Check there is a valid description for the reminder.
        guard descriptionTextView.text.count > 0 else {
            displayAlert(for: ProximityReminderError.invalidReminderDescription)
            return
        }
        
        // 2. Alert Segment will have arrive selected by default.
        // 3. Repeat value will be false by default.
        
        // 4. Check there is a valid location.
        guard let mapItem = mapItem else {
            displayAlert(for: ProximityReminderError.missingReminderLocation)
            return
        }
        
        // By this point in the validation, there should be enough info to schedule and save a reminder.
        let alertType: AlertType = (alertTypeSegment.selectedSegmentIndex == 0) ? .arriving : .leaving
        
        // Creates a new reminder and adds it to the current object context.
        let reminder = Reminder.create(withDescription: descriptionTextView.text, alertType: alertType, repeats: repeatToggle.isOn, fromMapItem: mapItem, inContext: CoreDataManager.sharedManager.managedObjectContext)
        
        scheduleLocationNotification(forReminder: reminder) { [weak self] (result) in
            switch result {
            case .success:
                // If the reminder was scheduled by the system successfully then save the UUID of that notification as the reminder UUID then try to save the object to core data.
                do {
                    print("SAVE SUCCESSFUL.")
                    try CoreDataManager.sharedManager.saveChanges()
                    self?.navigationController?.dismiss(animated: true, completion: nil) // Dismiss the nav controller that was presented modally.
                } catch {
                    print("Notification succeeded. Core data failed.")
                    // If soemthing goes wrong here the notification is probably still scheduled so that will need to be unscheduled.
                    self?.unscheduleLocationNotification(forIdentifier: reminder.uuid.uuidString)
                    self?.displayAlert(for: error)
                }
                
            case .failed(let error):
                print("Notif scheduling failed")
                self?.displayAlert(for: error) // If something went wrong, break the save proccess and alert the user.
                return
            }
        }
    }
    
    // MARK: Updating an Existing Reminder
    func updateExistingReminder() {
        // If the user made any changes, save them and reschule their notifications
        guard CoreDataManager.sharedManager.managedObjectContext.hasChanges, let reminder = reminder else {
            return
        }
        
        unscheduleLocationNotification(forIdentifier: reminder.uuid.uuidString)
        scheduleLocationNotification(forReminder: reminder) { [weak self] (schedulingResult) in
            // NOTE: This method gets called as the view is getting dismissed because the user pressed the back button so any errors will have to be sent to the parent.
            switch schedulingResult {
            case .success:
                do {
                    try CoreDataManager.sharedManager.saveChanges()
                    print("update succeeded")
                } catch {
                     self?.parent?.displayAlert(for: error)
                }
                
            case .failed(let error):
                self?.parent?.displayAlert(for: error)
            }
        }
    }

    @IBAction func alertTypeValueChanged(_ sender: UISegmentedControl) {
        reminder?.alertWhenLeaving = (sender.selectedSegmentIndex == 1) ? true : false // Arrive is position 0, leave is position 1.
    }
    
    @IBAction func repeatToggleChanged(_ sender: UISwitch) {
        reminder?.repeats = sender.isOn
    }
    
    // MARK: Delete Existing Reminder
    @IBAction func deleteTapped(_ sender: UIButton) {
        // Delete proccess: Unschedule notification, delete from CoreData, Save changes and pop view controller
        
        displayDeletePrompt(deleteDescription: "Are you sure you want to delete this reminder? Once deleted you will not be notified when you arrive at or leave this location.") { [weak self] (action) in
            guard let reminder = self?.reminder else { return }
            
            self?.unscheduleLocationNotification(forIdentifier: reminder.uuid.uuidString)
            CoreDataManager.sharedManager.managedObjectContext.delete(reminder)
            
            do {
                try CoreDataManager.sharedManager.saveChanges()
            } catch {
                self?.displayAlert(for: error)
            }
            
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
    
    /// MARK: Navigation Code
    @objc func dismissNewReminder() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ReminderDetailController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        reminder?.reminderDescription = textView.text
    }
}

extension ReminderDetailController: LocationSearchControllerDelegate {
    func userSelectedLocation(_ mapItem: MKMapItem) {
        locationButton.setTitle(mapItem.name, for: .normal)
        locationButton.isEnabled = true
        self.mapItem = mapItem
    }
}

extension ReminderDetailController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Calls a custom class method that gets the renderer
        return MKMapView.proximityCircleRenderer(for: overlay)
    }
}

extension ReminderDetailController: UserNotificationScheduler {
    // MARK: Check Location & Notification Authorization
    func checkAuthorization() {
        // Checks the user notification settings and the location permissions. If either are not allowed the user gets a permissions pop-up.
        getNotificationAuthorizationStatus { [weak self] (authorizationStatus) in
            guard authorizationStatus == .authorized && LocationManager.isAuthorized else {
                self?.presentPermissionsController()
                return
            }
        }
    }
    
    private func presentPermissionsController() {
        let permissionsController = storyboard!.instantiateViewController(withIdentifier: PermissionsController.storyboardIdentifier)
        present(permissionsController, animated: true, completion: nil)
    }
}
