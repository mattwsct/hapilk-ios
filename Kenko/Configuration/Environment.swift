//
//  Environment.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/10/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

enum Environment {
    
    // MARK: - Keys
    enum Keys {
        case hapilkAPI
        case hapilkWeb
        case hapilkContact
        
        var key: String {
            switch self {
            case .hapilkAPI: return "HAPILK_API"
            case .hapilkWeb: return "HAPILK_WEB"
            case .hapilkContact: return "HAPILK_CONTACT"
            }
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static func value(for key: Keys) -> String {
        guard let value = infoDictionary[key.key] as? String else {
            fatalError("\(key.key) is not set in plist for this environment")
        }
        return value
    }
    
}
