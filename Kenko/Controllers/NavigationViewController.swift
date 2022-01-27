//
//  NavigationViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 10/24/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class NavigationViewController: UITabBarController {
    
    var previousTabBarItem: UITabBarItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        previousTabBarItem = tabBarItem
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if previousTabBarItem == item {
            if let dashboardVC = selectedViewController as? DashboardViewController {
                dashboardVC.date = Date()
            }
        }
        previousTabBarItem = item
    }
}
