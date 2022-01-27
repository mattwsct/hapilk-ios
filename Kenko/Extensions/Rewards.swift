//
//  Rewards.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/30/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

struct RewardsResult: Codable {
    let rewards: Rewards
    
    private enum CodingKeys: String, CodingKey {
        case rewards = "response"
    }
}

struct Rewards: Codable {
    let userId: Int
    let points: Int
    let tickets: Int
    
    private enum CodingKeys: String, CodingKey {
        case userId = "userId",
            points = "points",
            tickets = "tickets"
    }
}
