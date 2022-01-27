//
//  String+HTML.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/3/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

extension Data {
    var HTMLToAttributedString: NSMutableAttributedString? {
        do {
            return try NSMutableAttributedString(
                data: self,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            return nil
        }
    }
}

extension String {
    var HTMLToAttributedString: NSMutableAttributedString? {
        return Data(utf8).HTMLToAttributedString
    }
}
