//
//  LocationManager.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 23/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import CoreLocation

class LocationManager: NSObject {
    
    static let LocationWhenInUsePermissionGranted = NSNotification.Name("LocationWhenInUsePermissionGranted")
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    func requestLocation() throws {
        // If the user does not have location services enabled in settings, then there's nothing further we can do apart from alert them.
        guard CLLocationManager.locationServicesEnabled() else {
            throw ProximityReminderError.locationServicesDisabled
        }
        
        // If location services are enabled, check the authorization status of this app.
        let status = CLLocationManager.authorizationStatus()
        guard status != .denied else {
            throw ProximityReminderError.locationServicesDeniedByUser
        }
        
        // Get the location and return it to the delegate.
        locationManager.requestLocation()
    }
    
    func requestAuthorization() throws {
        // Show the location permissions alert
        guard CLLocationManager.authorizationStatus() != .denied else {
            throw ProximityReminderError.locationServicesDeniedByUser
        }
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    static var isAuthorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse ? true : false
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            NotificationCenter.default.post(name: LocationManager.LocationWhenInUsePermissionGranted, object: nil)
        }
    }
}
