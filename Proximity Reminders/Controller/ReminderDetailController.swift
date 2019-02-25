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
    
    // MARK: Properties
    /// This reminder property is nil if the user is creating a new entry.
    var reminder: Reminder?
    
    var mapItem: MKMapItem? {
        didSet {
            configureMapView(with: mapItem)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reminder == nil {
            let leftBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ReminderDetailController.cancelReminder))
            let rightBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ReminderDetailController.saveReminder))
            navigationItem.leftBarButtonItem = leftBarButton
            navigationItem.rightBarButtonItem = rightBarButton
        }
        
        mapView.delegate = self
        
        checkAuthorization()
    }
    
    // MARK: Location Related Logic
    @IBAction func selectLocation() {
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
    
    
    /// Validates the input fields then attempts to schedule a reminder and subsequently save a reminder to core data
    @objc func saveReminder() {
        
        print("Saving...")
        
        // In order to make a valid save there must be:
        // - A valid reminder description >0 length
        // - A valid arrive/leave alert type
        // - A valid repeat value, will default to false
        // - A valid location.
        
        // 1. Check there is a valid description for the reminder.
        guard descriptionTextView.text.count > 0 else {
            showErrorAlert(for: ProximityReminderError.invalidReminderDescription)
            return
        }
        
        // 2. Alert Segment will have arrive selected by default.
        // 3. Repeat value will be false by default.
        
        // 4. Check there is a valid location.
        // TODO: Check location property and validate.
        guard let mapItem = mapItem else {
            showErrorAlert(for: ProximityReminderError.missingReminderLocation)
            return
        }
        
        // By this point in the validation, there should be enough info to schedule and save a reminder.
        
        let alertType: AlertType = (alertTypeSegment.selectedSegmentIndex == 0) ? .arriving : .leaving
        
        // Creates a new reminder and adds it to the current object context.
        let reminder = Reminder.create(withDescription: descriptionTextView.text, alertType: alertType, repeats: repeatToggle.isOn, fromMapItem: mapItem, inContext: CoreDataManager.sharedManager.managedObjectContext)
        
        scheduleLocationNotification(forReminder: reminder) { [weak self] (result) in
            switch result {
            case .success(let uuid):
                reminder.uuid = uuid
                
                // If the reminder was scheduled by the system successfully then save the UUID of that notification as the reminder UUID then try to save the object to core data.
                do {
                    print("SAVE SUCCESSFUL.")
                    try CoreDataManager.sharedManager.saveChanges()
                    self?.navigationController?.dismiss(animated: true, completion: nil) // Dismiss the nav controller that was presented modally.
                } catch {
                    print("Notificatio succeeded. Core data failed.")
                    // If soemthing goes wrong here the notification is probably still scheduled so that will need to be unscheduled.
                    self?.unscheduleLocationNotification(forIdentifier: uuid.uuidString)
                    self?.showErrorAlert(for: error)
                }
                
            case .failed(let error):
                print("Notif scheduling failed")
                self?.showErrorAlert(for: error) // If something went wrong, break the save proccess and alert the user.
                return
            }
        
            
        }
        
    }
    
    /// If the controller is presented in the add new reminder state, a left bar button item 'cancel' call this func to dimiss the view and it's nav controller
    @objc func cancelReminder() {
        navigationController?.dismiss(animated: true, completion: nil)
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
