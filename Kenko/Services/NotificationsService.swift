//
//  NotificationsService.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/19/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

struct NotificationsService {
    
    static func requestNotifications() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
}
