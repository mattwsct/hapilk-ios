//
//  ContactUsViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/24/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController {
    
    @IBOutlet weak var contactEmailWrapperView: UIView! {
        didSet {
            contactEmailWrapperView.layer.borderWidth = 0.5
            contactEmailWrapperView.layer.borderColor = UIColor.lightGray.cgColor
            contactEmailWrapperView.layer.cornerRadius = 10
            contactEmailWrapperView.layer.shadowColor = UIColor.lightGray.cgColor
            contactEmailWrapperView.layer.shadowRadius = 10
            contactEmailWrapperView.layer.shadowOpacity = 0.7
            contactEmailWrapperView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        }
    }
    
    @IBOutlet weak var contactEmailLabel: UILabel!
    let contactEmail = Environment.value(for: .hapilkContact)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactEmailLabel.text = contactEmail
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        let countryCode = UserDefaults.standard.string(forKey: "countryCode")!
        let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")!
        let userPhoneNumber = "+\(countryCode)\(phoneNumber)"
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "subject", value: "はぴるく問い合わせ - \(userPhoneNumber)"),
            URLQueryItem(name: "body", value: "")
        ]
        
        if let queryItems = urlComponents.url {
            if let url = URL(string: "mailto:\(contactEmail)\(queryItems)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func copyEmail(_ sender: Any) {
        UIPasteboard.general.string = contactEmail
        validationAlert(title: "Eメール", message: "メールアドレスをクリップボードにコピーしました")
    }
}
