//
//  CompanyRankingTableViewCell.swift
//  Kenko
//
//  Created by David Garcia Tort on 10/1/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class CompanyRankingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var positionBackgroundColorView: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var branchLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var amountPeopleLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
