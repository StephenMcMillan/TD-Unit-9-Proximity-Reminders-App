//
//  ProximityMap.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 23/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import MapKit

// Various helpers to assist with the drawing of the MapView and its overlay

extension MKMapView {
    /// Takes a name and adds a point with that name to the coordinate passed in
    /// Also takes a bool to remove existing annotations
    
    /// Drops a pointer on the map at the specified coordinate
    ///
    /// - Parameters:
    ///   - name: the name of the pin
    ///   - coordinate: the coordinate / center that the pin will be placed on the map
    ///   - clearExisting: a boolean value determining whether existing annotations are removed before this one is added.
    func dropPin(withName name: String?, at coordinate: CLLocationCoordinate2D, clearExisting: Bool = true) {
        
        if clearExisting {
            self.removeAnnotations(self.annotations)
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = name
        pointAnnotation.coordinate = coordinate
        self.addAnnotation(pointAnnotation)
    }
    
    /// Add an MKCircle overlay to the map with a center and radius specified
    ///
    /// - Parameters:
    ///   - centerCoordinate: the center point that the coordinate with be drawn around
    ///   - radius: the radius (in metres) to draw the circle. Default is 50m.
    ///   - clearExisting: a boolean value determining whether existing overlays are removed before this one is added.
    func drawCirlce(withCenter centerCoordinate: CLLocationCoordinate2D, radius: Double = 50, clearExisting: Bool = true) {
        
        if clearExisting {
            self.removeOverlays(self.overlays)
        }
        
        let overlay = MKCircle(center: centerCoordinate, radius: radius)
        self.addOverlay(overlay)
    }
    
    /// Static method that returns a pre-configured overlay renderer that is custom to this app.
    ///
    /// - Parameter overlay: the MKOverlay object that is being drawn
    /// - Returns: the pre-configured overlay renderer set-up with our custom styles.
    static func proximityCircleRenderer(for overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.3618691266, green: 0.7961515188, blue: 0.6061794758, alpha: 1)
        renderer.lineWidth = 3.0
        return renderer
    }
}
