//
//  Date+Encode.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/30/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

extension Date {
    var encodedUTCDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    var encodedUTCDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日 (EEEE)"
        return dateFormatter.string(from: self)
    }
    
    var encodedUTCIntervalDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd (EE)"
        return dateFormatter.string(from: self)
    }
    
    var encodedUTCDatetimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: self)
    }
}
