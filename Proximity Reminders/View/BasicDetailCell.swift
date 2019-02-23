//
//  BasicDetailCell.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 23/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

class BasicDetailCell: UITableViewCell {

    static let reuseIdentifier = "BasicDetailCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: BasicDetailCell.reuseIdentifier)
    }
    
    // This isn't needed for this basic cell.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
