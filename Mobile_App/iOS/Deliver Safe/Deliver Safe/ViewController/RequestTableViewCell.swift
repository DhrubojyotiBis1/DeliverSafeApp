//
//  RequestTableViewCell.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 21/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var requestDescription: UILabel!
    @IBOutlet weak var requestAuthor: UILabel!
    @IBOutlet weak var requestBackgroundView: UIView!
    @IBOutlet weak var creaetedDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.requestBackgroundView.layer.cornerRadius = 10
        setUp().makeCardView(forView: self.requestBackgroundView, withShadowHight: 4, shadowWidth: 0, shadowOpacity: 0.4, shadowRadius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
