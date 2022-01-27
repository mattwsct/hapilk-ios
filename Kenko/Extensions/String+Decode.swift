//
//  String+Decode.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/13/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

extension String {
    var decodedUTCDateDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)!
    }
    
    var decodedUTCDatetimeDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: self)!
    }
}
