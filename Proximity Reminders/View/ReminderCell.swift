//
//  ReminderCell.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 25/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var reminderDescriptionLabel: UILabel!
    @IBOutlet weak var reminderDetailLabel: UILabel!
    
    static let reuseIdentifier = String(describing: ReminderCell.self)
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if animated {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.contentBackgroundView.backgroundColor = selected ? #colorLiteral(red: 0.2466591597, green: 0.2723892331, blue: 0.4559572935, alpha: 0.7512574914) : #colorLiteral(red: 0.2466591597, green: 0.2723892331, blue: 0.4559572935, alpha: 1)
            }
        } else {
        contentBackgroundView.backgroundColor = selected ? #colorLiteral(red: 0.2466591597, green: 0.2723892331, blue: 0.4559572935, alpha: 0.7512574914) : #colorLiteral(red: 0.2466591597, green: 0.2723892331, blue: 0.4559572935, alpha: 1)        }
    }
    
}
