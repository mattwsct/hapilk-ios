//
//  Company.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/29/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

struct CompaniesResult: Codable {
    let companies: [Company]
    
    private enum CodingKeys: String, CodingKey {
        case companies = "response"
    }
}

struct BranchesResult: Codable {
    let branches: [Branch]
    
    private enum CodingKeys: String, CodingKey {
        case branches = "response"
    }
}

struct DepartmentsResult: Codable {
    let departments: [Department]
    
    private enum CodingKeys: String, CodingKey {
        case departments = "response"
    }
}

struct Company: Codable {
    let id: Int
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "companyId", name = "companyName"
    }
}

struct Branch: Codable {
    let id: Int
    let companyId: Int
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "branchId", companyId = "companyId", name = "branchName"
    }
}

struct Department: Codable {
    let id: Int
    let branchId: Int
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "departmentId", branchId = "branchId", name = "departmentName"
    }
}
