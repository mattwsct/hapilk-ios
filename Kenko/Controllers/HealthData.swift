//
//  HealthData.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/8/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

struct HealthDataResult: Codable {
    let healthData: [HealthData]
    
    private enum CodingKeys: String, CodingKey {
        case healthData = "response"
    }
}

struct HealthData: Codable {
    var steps: Double
    var calories: Double
    var goal: Double?
    var date: String
    
    init(steps: Double, calories: Double, goal: Double? = nil, date: String) {
        self.steps = steps
        self.calories = calories
        self.goal = goal
        self.date = date
    }
    
    private enum CodingKeys: String, CodingKey {
        case steps = "stepCount", calories = "caloryCount", goal = "goalSteps", date = "createdDate"
    }
}

struct GoalsResult: Codable {
    let goals: [Int]
    
    private enum CodingKeys: String, CodingKey {
        case goals = "response"
    }
}

struct GoalResult: Codable {
    let goal: Goal
    
    private enum CodingKeys: String, CodingKey {
        case goal = "response"
    }
}

struct Goal: Codable {
    var goal: Int
    
    private enum CodingKeys: String, CodingKey {
        case goal = "goalSteps"
    }
}
