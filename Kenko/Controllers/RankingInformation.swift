//
//  UserPersonalRankingInformation.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/5/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

struct UsersPersonalRankingInformationResult: Codable {
    let usersPersonalRankingInformation: [UserPersonalRankingInformation]
    
    private enum CodingKeys: String, CodingKey {
        case usersPersonalRankingInformation = "response"
    }
}

struct UserPersonalRankingInformationResult: Codable {
    let userPersonalRankingInformation: UserPersonalRankingInformation
    
    private enum CodingKeys: String, CodingKey {
        case userPersonalRankingInformation = "response"
    }
}

struct PrefecturesRankingInformationResult: Codable {
    let prefecturesRankingInformation: [PrefectureRankingInformation]
    
    private enum CodingKeys: String, CodingKey {
        case prefecturesRankingInformation = "response"
    }
}

struct CompaniesRankingInformationResult: Codable {
    let companiesRankingInformation: [CompanyRankingInformation]
    
    private enum CodingKeys: String, CodingKey {
        case companiesRankingInformation = "response"
    }
}

struct UserPersonalRankingInformation: Codable {
    let id: Int
    let position: Double
    let profilePicture: String?
    let name: String?
    let steps: Double
    let ageGroup: Int?
    let fromDate: String
    let toDate: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "userID",
        position = "rank",
        profilePicture = "profilePicture",
        name = "fullName",
        steps = "stepCount",
        ageGroup = "ageGroup",
        fromDate = "fromDate",
        toDate = "toDate"
    }
}

struct PrefectureRankingInformation: Codable {
    let prefectureId: Int
    let prefectureName: String
    let position: Double
    let steps: Double
    let people: Double
    let fromDate: String
    let toDate: String
    
    private enum CodingKeys: String, CodingKey {
        case prefectureId = "prefectureId",
        prefectureName = "prefectureName",
        position = "rank",
        steps = "stepCount",
        people = "totalPeople",
        fromDate = "fromDate",
        toDate = "toDate"
    }
}

struct CompanyRankingInformation: Codable {
    let companyId: Int
    let companyName: String
    let branchId: Int
    let branchName: String?
    let departmentId: Int
    let departmentName: String?
    let position: Double
    let steps: Double
    let people: Double
    let fromDate: String
    let toDate: String
    
    private enum CodingKeys: String, CodingKey {
        case companyId = "companyId",
        companyName = "companyName",
        branchId = "branchId",
        branchName = "branchName",
        departmentId = "departmentId",
        departmentName = "departmentName",
        position = "rank",
        steps = "stepCount",
        people = "totalPeople",
        fromDate = "fromDate",
        toDate = "toDate"
    }
}

enum RankingType {
    case individual
    case age
    case company
    case prefecture
}

enum RankingInterval {
    case daily
    case weekly
    case monthly
    
    var value: String {
        switch self {
        case .daily: return "DAILY"
        case .weekly: return "WEEKLY"
        case .monthly: return "MONTHLY"
        }
    }
}

enum RankingAgeGroup {
    case twenties
    case thirties
    case forties
    case fifties
    case sixties
    
    var value: Int {
        switch self {
        case .twenties: return 20
        case .thirties: return 30
        case .forties: return 40
        case .fifties: return 50
        case .sixties: return 60
        }
    }
}

extension String {
    var extractUserId: Int? {
        let queryItems = URLComponents(string: self)?.queryItems
        let userIdQueryItem = queryItems?.filter({ $0.name == "userID"}).first
        if let userId = userIdQueryItem?.value {
            return Int(userId)
        }
        return nil
    }
}
