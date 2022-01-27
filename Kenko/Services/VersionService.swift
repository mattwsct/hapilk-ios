//
//  VersionService.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/20/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

struct VersionService {
    
    static var remoteConfig = RemoteConfig.remoteConfig()
    static let settings = RemoteConfigSettings()
    
    static func initRemoteConfig() {
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        if let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            remoteConfig.setDefaults([
                "ios_version": NSString(string: localVersion)
            ])
        }
        
        let expirationDuration = 3600
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration), completionHandler: { (status, error) -> Void in
            if status == .success {
                self.remoteConfig.activate(completionHandler: nil)
            } else {
                if let error = error {
                    print("Not fetched, error: \(error.localizedDescription)")
                }
            }
        })
    }
    
    static func checkVersion() -> String? {
        initRemoteConfig()
        
        let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let remoteVersion = remoteConfig["ios_version"].stringValue
        
        if remoteVersion != localVersion {
            return remoteVersion
        }
        
        return nil
    }
    
}
