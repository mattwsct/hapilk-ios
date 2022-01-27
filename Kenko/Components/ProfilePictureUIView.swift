//
//  ProfilePictureUIView.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/6/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class ProfilePictureUIView: UIImageView {
    
    let defaultImage = #imageLiteral(resourceName: "Default_Profile")
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if image == nil {
            setDefaultImage()
        }
        
        layer.masksToBounds = false
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
    
    func setDefaultImage() {
        image = defaultImage
    }
    
}
