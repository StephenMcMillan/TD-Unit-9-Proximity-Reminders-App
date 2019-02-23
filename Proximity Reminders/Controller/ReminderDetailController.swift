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
        
        mapView.removeAnnotations(mapView.annotations)
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = mapItem.placemark.coordinate
        pointAnnotation.title = mapItem.name
        mapView.addAnnotation(pointAnnotation)
        
        mapView.region = MKCoordinateRegion(center: mapItem.placemark.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        
        let overlay = MKCircle(center: pointAnnotation.coordinate, radius: CLLocationDistance(exactly: 50)!)
        mapView.addOverlay(overlay)
    }
    
    @objc func saveReminder() {
        
        print("Saving...")
        
        
        // 1. Check there is a valid description for the reminder.
        guard descriptionTextView.text.count > 0 else {
            showErrorAlert(for: ProximityReminderError.invalidReminderDescription)
            return
        }
        
        // 2. Alert Segment will have arrive selected by default.
        // 3. Repeat value will be false by default.
        
        // 4. Check there is a valid location.
        // TODO: Check location property and validate.
        
        
        // In order to make a valid save there must be:
        // - A valid reminder description >0 length
        // - A valid arrive/leave alert type
        // - A valid repeat value, will default to false
        // - A valid location.
        
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
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 3.0
        return renderer
    }
}
