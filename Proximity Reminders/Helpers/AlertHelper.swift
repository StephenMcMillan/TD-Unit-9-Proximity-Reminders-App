//
//  AlertHelper.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

// This extension of UIViewController makes it more convenient to create and present alerts.
extension UIViewController {
    
    // Helper function that takes an error and shows an alert to the user.
    func showErrorAlert(for error: Error?) {
        let alert = UIAlertController(title: "Oh No!", message: "Something wasn't quite right. \(error?.localizedDescription ?? "")", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
