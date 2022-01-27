//
//  Network.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/3/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Kingfisher

struct Network {
    
    static let provider = MoyaProvider<KenkoAPI>(plugins: [
        AccessTokenPlugin(tokenClosure: { return UserDefaults.standard.string(forKey: "userToken") ?? "" }),
        NetworkLoggerPlugin(verbose: true),
    ])
    
    static func request(
        target: KenkoAPI,
        success successCallback: @escaping (JSON) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    if json["status"].bool == true {
                        successCallback(json["response"])
                    } else {
                        throw KenkoAPIError.responseError(message: json["message"].string!)
                    }
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getCompanies(
        success: @escaping ([Company]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.companies) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(CompaniesResult.self, from: response.data)
                    success(results.companies)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getBranches(
        companyId: Int,
        success: @escaping ([Branch]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.branches(company: companyId)) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(BranchesResult.self, from: response.data)
                    success(results.branches)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getDepartments(
        branchId: Int,
        success: @escaping ([Department]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.departments(branch: branchId)) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(DepartmentsResult.self, from: response.data)
                    success(results.departments)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getPrefectures(
        success: @escaping ([Prefecture]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.prefectures) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(PrefecturesResult.self, from: response.data)
                    success(results.prefectures)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getUserProfile(
        success: @escaping (UserProfile) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.getUserProfile) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(UserProfileResult.self, from: response.data)
                    success(results.userProfile)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getUserProfilePicture(
        success: @escaping (Data) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        let cache = ImageCache.default
        cache.memoryStorage.config.expiration = .days(1)
        cache.diskStorage.config.expiration = .days(7)
        let cacheKey = "profilePicture"
        let cached = cache.isCached(forKey: cacheKey)
        
        if cached == true {
            cache.retrieveImage(forKey: cacheKey, completionHandler: { result in
                switch result {
                case .success(let image):
                    if let image = image.image?.jpegData(compressionQuality: 1) {
                        success(image)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        } else {
            provider.request(.getUserProfilePicture) { result in
                switch result {
                case .success(let response):
                    if !response.data.isEmpty {
                        if let image = UIImage(data: response.data) {
                            cache.store(image, original: response.data, forKey: cacheKey)
                            success(response.data)
                        }
                    }
                case .failure(let error):
                    failureCallback(error)
                }
            }
        }
    }
    
    static func getUsersProfilePicture(
        userId: Int,
        success: @escaping (Data) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        let cache = ImageCache.default
        cache.memoryStorage.config.expiration = .days(1)
        cache.diskStorage.config.expiration = .days(1)
        let cacheKey = String(userId)
        let cached = cache.isCached(forKey: cacheKey)
        
        if cached == true {
            cache.retrieveImage(forKey: cacheKey, completionHandler: { result in
                switch result {
                case .success(let image):
                    if let image = image.image?.jpegData(compressionQuality: 1) {
                        success(image)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        } else {
            provider.request(.getUsersProfilePicture(userId: userId)) { result in
                switch result {
                case .success(let response):
                    if !response.data.isEmpty {
                        if let image = UIImage(data: response.data) {
                            cache.store(image, original: response.data, forKey: cacheKey)
                            success(response.data)
                        }
                    }
                case .failure(let error):
                    failureCallback(error)
                }
            }
        }
    }
    
    static func getUserHealthData(
        start: Date,
        end: Date,
        success: @escaping ([HealthData]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.getUserHealthData(start: start.encodedUTCDateString, end: end.encodedUTCDateString)) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(HealthDataResult.self, from: response.data)
                    success(results.healthData)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getIndividualRanking(
        interval: RankingInterval,
        success: @escaping ([UserPersonalRankingInformation]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.individualRanking(interval: interval)) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(UsersPersonalRankingInformationResult.self, from: response.data)
                    success(results.usersPersonalRankingInformation)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getUserIndividualRanking(
        interval: RankingInterval,
        success: @escaping (UserPersonalRankingInformation) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.userIndividualRanking(interval: interval)) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(UserPersonalRankingInformationResult.self, from: response.data)
                    success(results.userPersonalRankingInformation)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getAgeRanking(
        group: RankingAgeGroup,
        success: @escaping ([UserPersonalRankingInformation]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.ageRanking(group: group)) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(UsersPersonalRankingInformationResult.self, from: response.data)
                    success(results.usersPersonalRankingInformation)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getUserAgeRanking(
        group: RankingAgeGroup,
        success: @escaping (UserPersonalRankingInformation) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.userAgeRanking) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(UserPersonalRankingInformationResult.self, from: response.data)
                    success(results.userPersonalRankingInformation)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getCompanyRanking(
        success: @escaping ([CompanyRankingInformation]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.companyRanking) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(CompaniesRankingInformationResult.self, from: response.data)
                    success(results.companiesRankingInformation)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getPrefectureRanking(
        success: @escaping ([PrefectureRankingInformation]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.prefectureRanking) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(PrefecturesRankingInformationResult.self, from: response.data)
                    success(results.prefecturesRankingInformation)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getRewards(
        success: @escaping (Rewards) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.rewards) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(RewardsResult.self, from: response.data)
                    success(results.rewards)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getGoalsList(
        success: @escaping ([Int]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.goals) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(GoalsResult.self, from: response.data)
                    success(results.goals)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getGoal(
        success: @escaping (Goal) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.goal) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(GoalResult.self, from: response.data)
                    success(results.goal)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getAnnouncements(
        success: @escaping ([Announcement]) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(.announcements) { result in
            switch result {
            case .success(let response):
                do {
                    let results = try JSONDecoder().decode(AnnouncementsResult.self, from: response.data)
                    success(results.announcements)
                } catch let error {
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
    static func getAnnouncementPicture(
        announcementId: Int,
        success: @escaping (Data) -> Void,
        error errorCallback: @escaping (Swift.Error) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        let cache = ImageCache.default
        cache.memoryStorage.config.expiration = .seconds(600)
        cache.diskStorage.config.expiration = .seconds(600)
        let cacheKey = String("announcement_\(announcementId)")
        let cached = cache.isCached(forKey: cacheKey)
        
        if cached == true {
            cache.retrieveImage(forKey: cacheKey, completionHandler: { result in
                switch result {
                case .success(let image):
                    if let image = image.image?.jpegData(compressionQuality: 1) {
                        success(image)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        } else {
            provider.request(.announcementPicture(announcementId: announcementId)) { result in
                switch result {
                case .success(let response):
                    if !response.data.isEmpty {
                        if let image = UIImage(data: response.data) {
                            cache.store(image, original: response.data, forKey: cacheKey)
                            success(response.data)
                        }
                    }
                case .failure(let error):
                    failureCallback(error)
                }
            }
        }
    }
    
}

enum KenkoAPIError: LocalizedError {
    case responseError(message: String)
}

extension KenkoAPIError {
    var errorDescription: String? {
        switch self {
        case let .responseError(message: message):
            return message
        }
    }
}
