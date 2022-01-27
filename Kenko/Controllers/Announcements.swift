//
//  Announcements.swift
//  Kenko
//
//  Created by David Garcia Tort on 11/18/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

struct AnnouncementsResult: Codable {
    let announcements: [Announcement]
    
    private enum CodingKeys: String, CodingKey {
        case announcements = "response"
    }
}

struct Announcement: Codable {
    let id: Int
    let title: String
    let image: String?
    var description: String
    let url: String?
    let order: Int
    var enabled: Bool = true
    
    private enum CodingKeys: String, CodingKey {
        case id = "id",
            title = "title",
            image = "imageUrl",
            description = "description",
            url = "announcementUrl",
            order = "displayOrder"
    }
}
