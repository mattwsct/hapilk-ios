//
//  RoundedUITextField.swift
//  Kenko
//
//  Created by David Garcia Tort on 6/17/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedUITextField: UITextField {

    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.masksToBounds = true
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
