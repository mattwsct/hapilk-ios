//
//  PersonalRankingTableViewCell.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/5/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class UserRankingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var positionBackgroundColorView: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var profilePictureView: ProfilePictureUIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
