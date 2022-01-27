//
//  UserProfile.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/25/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

struct UserProfileResult: Codable {
    let userProfile: UserProfile
    
    private enum CodingKeys: String, CodingKey {
        case userProfile = "response"
    }
}

struct UserProfile: Codable {
    var height: Double?
    var weight: Double?
    var birthday: String?
    var employeeNumber: String?
    var companyId: Int?
    var company: String?
    var branchId: Int?
    var branch: String?
    var departmentId: Int?
    var department: String?
    var name: String?
    var displayName: String?
    var prefectureId: Int?
    var prefectureCode: String?
    var prefecture: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case height = "height",
            weight = "weight",
            birthday = "dateOfBirth",
            employeeNumber = "employeeId",
            companyId = "companyId",
            company = "companyName",
            branchId = "branchId",
            branch = "branchName",
            departmentId = "departmentId",
            department = "departmentName",
            name = "fullName",
            displayName = "nickName",
            prefectureId = "prefectureId",
            prefectureCode = "prefectureCode",
            prefecture = "prefectureName"
    }
}
