//
//  ActivityTableViewCell.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 22/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityBackgroundView: UIView!
    @IBOutlet weak var activityAssinTo: UILabel!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var activityDescription: UILabel!
    @IBOutlet weak var activityAuthor: UILabel!
    @IBOutlet weak var activityCreatedDate: UILabel!
    @IBOutlet weak var isAssignView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.activityBackgroundView.layer.cornerRadius = 10
        setUp().makeCardView(forView: self.activityBackgroundView, withShadowHight: 4, shadowWidth: 0, shadowOpacity: 0.4, shadowRadius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
