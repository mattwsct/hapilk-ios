//
//  SharingViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/3/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class SharingViewController: UIViewController {

    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet weak var downloadAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Generate QR
        let downloadAddress = "\(Environment.value(for: .hapilkWeb))/download"
        downloadAddressLabel.text = downloadAddress
        DispatchQueue.main.async {
            self.QRCodeImageView.image = downloadAddress.convertToQRCode
        }
    }

    @IBAction func shareDownloadAddress(_ sender: Any) {
        let url = URL(string: downloadAddressLabel.text!)!
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
    
}
