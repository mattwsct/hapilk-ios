//
//  AnnouncementViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 11/18/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class AnnouncementViewController: UIViewController {
    
    var announcement: Announcement?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let announcement = announcement {
            titleLabel.text = announcement.title
            imageView.isHidden = announcement.image == nil
            if announcement.image == nil {
                imageView.isHidden = true
            } else {
                Network.getAnnouncementPicture(announcementId: announcement.id, success: { announcementPicture in
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: announcementPicture)
                    }
                }, error: { error in }, failure: { error in })
            }
            descriptionLabel.text = announcement.description
            urlButton.isHidden = announcement.url == nil
        }
    }
    
    @IBAction func urlButtonPressed(_ sender: Any) {
        if let announcement = announcement, let announcementUrl = announcement.url {
            if let url = URL(string: announcementUrl) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

}
