//
//  TicketViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 10/23/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class TicketViewController: UIViewController {

    @IBOutlet weak var ticketView: UIView! {
        didSet {
            ticketView.layer.masksToBounds = true
            ticketView.layer.cornerRadius = 8
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closePopupView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
