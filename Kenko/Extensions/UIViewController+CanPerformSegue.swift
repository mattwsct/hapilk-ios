//
//  UIViewController+CanPerformSegue.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/12/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /**
     Checks whether controller can perform specific segue or not.
     - parameter identifier: Identifier of UIStoryboardSegue.
     */
    func canPerformSegue(withIdentifier identifier: String) -> Bool {
        //first fetch segue templates set in storyboard.
        guard let identifiers = value(forKey: "storyboardSegueTemplates") as? [NSObject] else {
            //if cannot fetch, return false
            return false
        }
        //check every object in segue templates, if it has a value for key _identifier equals your identifier.
        let canPerform = identifiers.contains { (object) -> Bool in
            if let id = object.value(forKey: "_identifier") as? String {
                if id == identifier {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        return canPerform
    }
}
