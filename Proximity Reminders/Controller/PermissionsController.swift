//
//  PermissionsController.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 23/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import UserNotifications

class PermissionsController: UIViewController, UserNotificationScheduler {
    
    // MARK: Interface Builder Outlets
    @IBOutlet weak var locationAccessButton: UIButton!
    @IBOutlet weak var notificationAccessButton: UIButton!
    @IBOutlet weak var locationPermissionsCheckmark: UIImageView!
    @IBOutlet weak var notificationPermissionsCheckmark: UIImageView!
    
    // MARK: Propertie
    static let storyboardIdentifier = String(describing: PermissionsController.self)
    let locationManager = LocationManager()
    
    // MARK: Initial Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If the user has not already authroized location permissions then setup the button accordingly and add an observer to listen for the permission granted notification from the LocationManager class.
        if !LocationManager.isAuthorized {
            NotificationCenter.default.addObserver(self, selector: #selector(PermissionsController.configureLocationButton), name: .locationWhenInUsePermissionGranted, object: nil)
        }
        
        configureLocationButton()
        
        // When the permissions view first loads, check whether notifications have been authorized or not.
        getNotificationAuthorizationStatus { [weak self] (status) in
            self?.configureNotificationButton(isAuthorized: status == UNAuthorizationStatus.authorized)
        }
        
    }
    
    // MARK: Location Authorization
    @objc func configureLocationButton() {
        // If location is authorized, disable the button and show the checkmark. Otherwise enabled the button and hide the checkmark.
        let locationAuthorized = LocationManager.isAuthorized
        locationAccessButton.isEnabled = !locationAuthorized
        locationPermissionsCheckmark.isHidden = !locationAuthorized
    }
    
    @IBAction func allowLocation() {
        // Try to request authorization from the Location Manager. If the method throws, the user likely denied permission previously.
        do {
            try locationManager.requestAuthorization()
        } catch {
            displayAlert(for: error)
        }
    }
    
    // MARK: Notification Authorization
    func configureNotificationButton(isAuthorized: Bool) {
        // If the bool is true then the button is disabled and a checkmark is shown because there is no need for a user to request permission again. Otherwise the button is enabled and the checkmark is hidden.
        DispatchQueue.main.async {
            self.notificationAccessButton.isEnabled = !isAuthorized
            self.notificationPermissionsCheckmark.isHidden = !isAuthorized
        }
    }
    
    @IBAction func allowNotifications() {
        // Makes a call to location manager to request notification permissions and updates the button when the
        
        // If the user tries to allow notifications and they've already denied previously then this button is not going to work so it is neccessary to display an alert.
        
        getNotificationAuthorizationStatus { [weak self] (authorizationStatus) in
            guard authorizationStatus != .denied else {
                self?.displayAlert(for: ProximityReminderError.notificationsDeniedByUser)
                return
            }
            
            self?.requestNotificationPermissions(completion: { [weak self] (isAuthorized, error) in
                if let error = error {
                    self?.displayAlert(for: error)
                }
                self?.configureNotificationButton(isAuthorized: isAuthorized)
            })
        }
    }
    
    // MARK: Misc Methods
    
    @IBAction func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // Deint to remove notification center observers
    deinit {
        NotificationCenter.default.removeObserver(self, name: .locationWhenInUsePermissionGranted, object: nil)
    }
}
