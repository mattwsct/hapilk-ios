//
//  GeneralRankingTableViewCell.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/6/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class GeneralRankingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var positionBackgroundColorView: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountPeopleLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
