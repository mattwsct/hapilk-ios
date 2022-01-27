//
//  UITextField+MaxLength.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/17/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import UIKit

private var maxLengths = [UITextField: Int]()

extension UITextField {
    @IBInspectable
    var maxLength: Int {
        get {
            guard let length = maxLengths[self] else {
                return Int.max
            }
            return length
        }
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(limitLength(textField:)), for: .editingChanged)
        }
    }
    
    @objc func limitLength(textField: UITextField) {
        guard let prospectiveText = textField.text, prospectiveText.count > maxLength else {
            return
        }
        
        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        
        text = String(prospectiveText[..<maxCharIndex])
        
        selectedTextRange = selection
    }
}
