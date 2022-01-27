//
//  ColoredUITabBarItem.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/22/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class ColoredUITabBarItem: UITabBarItem {

    override func awakeFromNib() {
        if let image = image {
            self.image = image.withRenderingMode(.alwaysOriginal)
        }
        if let image = selectedImage {
            selectedImage = image.withRenderingMode(.alwaysOriginal)
        }
    }
}
