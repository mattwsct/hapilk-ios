//
//  SettingsViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/4/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import UserNotifications
import Kingfisher

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var dataSyncSwitch: UISwitch!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Switches
        dataSyncSwitch.addTarget(self, action: #selector(toggleSettings(switchState:)), for: .valueChanged)
        notificationsSwitch.addTarget(self, action: #selector(toggleSettings(switchState:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(updateToggleViews), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        updateVersionLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNotificationsSwitch()
    }
    
    @objc func toggleSettings(switchState: UISwitch) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func updateToggleViews() {
        updateSynchronizationSwitch()
        updateNotificationsSwitch()
    }
    
    private func updateVersionLabel() {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        versionLabel.text = "\(appName!) \(appVersion!) (\(appBundle!))"
    }
    
    private func updateSynchronizationSwitch() {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .available:
            dataSyncSwitch.isOn = true
        default:
            dataSyncSwitch.isOn = false
        }
    }
    
    private func updateNotificationsSwitch() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    self.notificationsSwitch.isOn = true
                }
            default:
                DispatchQueue.main.async {
                    self.notificationsSwitch.isOn = false
                }
            }
        })
    }
    
    @IBAction func logout(_ sender: Any) {
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let logoutButton = UIAlertAction(title: "ログアウト", style: .destructive, handler: { action in
            UserDefaults.standard.removeObject(forKey: "userToken")
            let cache = ImageCache.default
            let cacheKey = "profilePicture"
            cache.removeImage(forKey: cacheKey)
            if let login = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() {
                UIApplication.shared.keyWindow?.rootViewController = login
            }
        })
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(cancelButton)
        alertController.addAction(logoutButton)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func unwindToSettings(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
