//
//  HealthService.swift
//  Kenko
//
//  Created by David Garcia Tort on 6/24/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

struct HealthService {
    
    enum HealthType {
        case steps
        case calories
        
        var typeIdentifier: HKObjectType {
            switch self {
            case .steps: return HKObjectType.quantityType(forIdentifier: .stepCount)!
            case .calories: return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
            }
        }
        
        static var allTypes: [HKObjectType] = [
            HealthType.steps.typeIdentifier,
            HealthType.calories.typeIdentifier
        ]
    }
    
    static let healthStore = HKHealthStore()
    
    static func initHealthStore() {
        let allTypes = Set(HealthType.allTypes)
        healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
            if !success {
            }
        }
    }
    
    static func checkHealthDataAvailability() {
        if HKHealthStore.isHealthDataAvailable() {
            initHealthStore()
        }
    }
    
    static func stepsCount(date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.startOfDay(
            for: Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: startOfDay)!
        )
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: startOfDay),
            end: endOfDay,
            options: []
        )
        let stepsQuery = HKStatisticsQuery(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            completionHandler: { query, result, error in
                var steps: Double?
                
                if let result = result {
                    steps = result.sumQuantity()?.doubleValue(for: .count())
                    DispatchQueue.main.async {
                        completion(steps, error)
                    }
                }
        })
        healthStore.execute(stepsQuery)
    }
    
    static func caloriesCount(date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.startOfDay(
            for: Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: startOfDay)!
        )
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: startOfDay),
            end: endOfDay,
            options: []
        )
        let caloriesQuery = HKStatisticsQuery(
            quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            completionHandler: { query, result, error in
                var calories: Double?
                
                if let result = result {
                    calories = result.sumQuantity()?.doubleValue(for: .kilocalorie())
                    DispatchQueue.main.async {
                        completion(calories, error)
                    }
                }
        })
        healthStore.execute(caloriesQuery)
    }
    
    static func getHealthData(of types: [HealthType], for dates: [Date], withCompletion completion: @escaping ([HealthData]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            var healthData: [HealthData] = []
            let healthGroupDate = DispatchGroup()
            let healthGroupDates = DispatchGroup()
            
            for date in dates {
                var stepsTotal: Double?
                var caloriesTotal: Double?
                
                healthGroupDates.enter()
                
                for type in types {
                    
                    healthGroupDate.enter()
                    
                    switch type {
                    case .steps:
                        self.stepsCount(date: date, completion: { steps, error in
                            stepsTotal = steps
                            healthGroupDate.leave()
                        })
                    case .calories:
                        self.caloriesCount(date: date, completion: { calories, error in
                            caloriesTotal = calories
                            healthGroupDate.leave()
                        })
                    }
                }
                
                healthGroupDate.wait()
                
                if let steps = stepsTotal, let calories = caloriesTotal {
                    healthData.append(HealthData(steps: steps, calories: calories, date: date.encodedUTCDateString))
                }
                
                healthGroupDates.leave()
            }
            
            healthGroupDates.wait()
            
            if healthData.isEmpty {
                DispatchQueue.main.sync {
                    let appState = UIApplication.shared.applicationState
                    
                    switch appState {
                    case .active:
                        showPermissionsAlert()
                    default: break
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(healthData)
            }
        }
    }
    
    static private func showPermissionsAlert() {
        if let viewController = UIApplication.shared.keyWindow?.rootViewController?.children.first {
            let alertController = UIAlertController(title: "HealthKit", message: "ヘルスケアデータとの連携の許可が必要です", preferredStyle: .alert)
            let settingsButton = UIAlertAction(title: "設定", style: .default, handler: { alert in
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            let cancelButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(settingsButton)
            alertController.addAction(cancelButton)
            
            DispatchQueue.main.async {
                viewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}
