//
//  JapanPrefectures.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/29/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

struct PrefecturesResult: Decodable {
    let prefectures: [Prefecture]
    
    private enum CodingKeys: String, CodingKey {
        case prefectures = "response"
    }
}

struct Prefecture: Codable {
    let id: Int
    let code: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case id = "id",
            code = "prefectureCode",
            name = "prefectureName"
    }
}
