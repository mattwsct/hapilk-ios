//
//  UIViewController+ValidationAlert.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/4/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func validationAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            guard let completion = completion else { return }
            completion()
        }))
        self.present(alert, animated: true)
    }
}
