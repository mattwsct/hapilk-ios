//
//  KenkoAPI.swift
//  Kenko
//
//  Created by David Garcia Tort on 6/21/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Moya

enum KenkoAPI {
    case register(countryCode: String, phoneNumber: String, password: String)
    case login(countryCode: String, phoneNumber: String, password: String)
    case logout
    case updatePassword(oldPassword: String, password: String)
    case updatePhoneNumber(countryCode: String, phoneNumber: String)
    case resetPasswordCode(countryCode: String, phoneNumber: String)
    case resetPassword(countryCode: String, phoneNumber: String, otpNumber: String, password: String)
    case companies
    case branches(company: Int)
    case departments(branch: Int)
    case prefectures
    case getUserProfile
    case updateUserProfile(height: Double?, weight: Double?, birthday: String?, employeeNumber: String?, companyId: Int?, company: String?, branchId: Int?, branch: String?, departmentId: Int?, department: String?, name: String?, displayName: String?, prefectureId: Int?, prefectureCode: String?, prefecture: String?)
    case getUserProfilePicture
    case getUsersProfilePicture(userId: Int)
    case updateUserProfilePicture(profilePicture: Data)
    case getUserHealthData(start: String, end: String)
    case updateUserHealthData(healthData: [HealthData])
    case individualRanking(interval: RankingInterval)
    case userIndividualRanking(interval: RankingInterval)
    case ageRanking(group: RankingAgeGroup)
    case userAgeRanking
    case companyRanking
    case prefectureRanking
    case rewards
    case goals
    case goal
    case updateGoal(goal: Int)
    case announcements
    case announcementPicture(announcementId: Int)
}

extension KenkoAPI: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        return URL(string: Environment.value(for: .hapilkAPI))!
    }
    
    var path: String {
        switch self {
        case .register: return "/token/register"
        case .login: return "/token/loginByPhoneNumber"
        case .logout: return "/token/logout"
        case .updatePassword: return "/rest/user/updatePassword"
        case .updatePhoneNumber: return "/rest/user/updatePhoneNumber"
        case .resetPasswordCode: return "/token/requestPasswordReset"
        case .resetPassword: return "/token/resetPassword"
        case .companies: return "/rest/userProfile/senkoGroupCompanies"
        case .branches: return "/rest/userProfile/branchOffices"
        case .departments: return "/rest/userProfile/departments"
        case .prefectures: return "/rest/userProfile/jpPrefectures"
        case .getUserProfile: return "/rest/userProfile/employeeProfile"
        case .updateUserProfile: return "/rest/userProfile/updateUserProfileInfo"
        case .getUserProfilePicture: return "/rest/userProfile/profilePicture"
        case .getUsersProfilePicture: return "/rest/userProfile/userProfilePicture"
        case .updateUserProfilePicture: return "/rest/userProfile/uploadProfilePicture"
        case .getUserHealthData: return "/rest/employee/healthdata/healthData"
        case .updateUserHealthData: return "/rest/employee/healthdata/pushHealthData"
        case .individualRanking: return "/rest/employee/ranking/topList"
        case .userIndividualRanking: return "/rest/employee/ranking/userRanking"
        case .ageRanking: return "/rest/employee/ranking/topListByAgeGroup"
        case .userAgeRanking: return "/rest/employee/ranking/userByAgeGroupRanking"
        case .companyRanking: return "/rest/employee/ranking/topListByCompanyWide"
        case .prefectureRanking: return "/rest/employee/ranking/topListByPrefectureGroup"
        case .rewards: return "/rest/employee/ranking/userRewards"
        case .goals: return "/rest/userProfile/stepCountGoals"
        case .goal: return "/rest/userProfile/userStepCountGoal"
        case .updateGoal: return "/rest/userProfile/updateStepCountGoal"
        case .announcements: return "/rest/announcements/announcements"
        case .announcementPicture: return "/rest/announcements/announcementImageUrl"
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .register, .login:
            return .none
        default:
            return .custom("Token")
            // return .bearer
        }
    }
    
    var method: Method {
        switch self {
        case .logout, .getUserProfilePicture, .getUsersProfilePicture, .announcementPicture:
            return .get
        case .register, .login, .updatePassword, .updatePhoneNumber, .resetPasswordCode, .resetPassword, .companies, .branches, .departments, .prefectures, .getUserProfile, .updateUserProfile, .updateUserProfilePicture, .getUserHealthData, .updateUserHealthData, .individualRanking, .userIndividualRanking, .ageRanking, .userAgeRanking, .companyRanking, .prefectureRanking, .rewards, .goals, .goal, .updateGoal, .announcements:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        default: return "{}".utf8Encoded
        }
    }
    
    var task: Task {
        switch self {
        case let .register(countryCode, phoneNumber, password):
            return .requestParameters(parameters: ["countryCode": countryCode, "phoneNumber": phoneNumber, "password": password], encoding: JSONEncoding.default)
        case let .login(countryCode, phoneNumber, password):
            return .requestParameters(parameters: ["countryCode": countryCode, "phoneNumber": phoneNumber, "password": password], encoding: JSONEncoding.default)
        case .logout:
            return .requestPlain
        case let .updatePassword(oldPassword, password):
            return .requestParameters(parameters: ["oldPassword": oldPassword, "newPassword": password], encoding: JSONEncoding.default)
        case let .updatePhoneNumber(countryCode, phoneNumber):
            return .requestParameters(parameters: ["countryCode": countryCode, "newPhoneNumber": phoneNumber], encoding: URLEncoding.queryString)
        case let .resetPasswordCode(countryCode, phoneNumber):
            return .requestParameters(parameters: ["countryCode": countryCode, "phoneNumber": phoneNumber], encoding: JSONEncoding.default)
        case let .resetPassword(countryCode, phoneNumber, otpNumber, password):
            return .requestParameters(parameters: ["countryCode": countryCode, "phoneNumber": phoneNumber, "otpNumber": otpNumber, "newPassword": password], encoding: JSONEncoding.default)
        case .companies:
            return .requestPlain
        case let .branches(company):
            return .requestParameters(parameters: ["companyId": company], encoding: URLEncoding.queryString)
        case let .departments(branch):
            return .requestParameters(parameters: ["branchId": branch], encoding: URLEncoding.queryString)
        case .prefectures:
            return .requestPlain
        case .getUserProfile:
            return .requestPlain
        case let .updateUserProfile(height, weight, birthday, employeeNumber, companyId, company, branchId, branch, departmentId, department, name, displayName, prefectureId, prefectureCode, prefecture):
            return .requestParameters(parameters: [
                "height": height ?? NSNull(),
                "weight": weight ?? NSNull(),
                "dateOfBirth": birthday ?? NSNull(),
                "employeeId": employeeNumber ?? NSNull(),
                "companyId": companyId ?? NSNull(),
                "companyName": company ?? NSNull(),
                "branchId": branchId ?? NSNull(),
                "branchName": branch ?? NSNull(),
                "departmentId": departmentId ?? NSNull(),
                "departmentName": department ?? NSNull(),
                "fullName": name ?? NSNull(),
                "nickName": displayName ?? NSNull(),
                "prefectureId": prefectureId ?? NSNull(),
                "prefectureCode": prefectureCode ?? NSNull(),
                "prefectureName": prefecture ?? NSNull(),
            ], encoding: JSONEncoding.default)
        case .getUserProfilePicture:
            return .requestPlain
        case let .getUsersProfilePicture(userId):
            return .requestParameters(parameters: ["userID": userId], encoding: URLEncoding.queryString)
        case let .updateUserProfilePicture(profilePicture):
            let profilePictureData = MultipartFormData(provider: .data(profilePicture), name: "file", fileName: "userProfile.jpg", mimeType: "image/jpeg")
            let multipartData = [profilePictureData]
            return .uploadMultipart(multipartData)
        case let .getUserHealthData(start, end):
            return .requestParameters(parameters: ["startDate": start, "endDate": end], encoding: URLEncoding.queryString)
        case let .updateUserHealthData(healthData):
            return .requestJSONEncodable(healthData)
        case let .individualRanking(interval):
            return .requestParameters(parameters: ["intervals": interval.value], encoding: URLEncoding.queryString)
        case let .userIndividualRanking(interval):
            return .requestParameters(parameters: ["intervals": interval.value], encoding: URLEncoding.queryString)
        case let .ageRanking(group):
            return .requestParameters(parameters: ["ageGroup": group.value], encoding: URLEncoding.queryString)
        case .userAgeRanking:
            return .requestPlain
        case .companyRanking:
            return .requestPlain
        case .prefectureRanking:
            return .requestPlain
        case .rewards:
            return .requestPlain
        case .goals:
            return .requestPlain
        case .goal:
            return .requestPlain
        case let .updateGoal(goal):
            return .requestParameters(parameters: ["goalSteps": goal], encoding: URLEncoding.queryString)
        case .announcements:
            return .requestPlain
        case let .announcementPicture(announcementId):
            return .requestParameters(parameters: ["announcementId": announcementId], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
