//
//  ViewDropsTableViewCell.swift
//  AidDrop
//
//  Created by John Corry on 12/14/17.
//  Copyright © 2017 John Corry. All rights reserved.
//

import UIKit
import CoreLocation

class ViewDropsTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with drop: Drop, from: CLLocation) {
        self.distanceLabel.text = "\(drop.getDistanceInKm(from: from)) km"
        
        if let dropTime = drop.created {
            let now = Date()
            let components = Calendar.current.dateComponents([.hour, .minute], from: dropTime as Date, to: now)
            
            
            let dropAgeString = "\(components.minute!) min"
            /**
             if components.hour > 0 {
             dropAgeString += "\(components.hour) hr "
             }
             if components.minute > 0 {
             dropAgeString += "\(components.minute) min"
             }
             */
            self.ageLabel.text = dropAgeString
        }
        
        print("\(drop)");
    }

}
