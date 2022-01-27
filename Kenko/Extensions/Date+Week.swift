//
//  Date+Week.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/27/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation

extension Date {
    
    var iso8601Calendar: Calendar {
        let calendar = Calendar(identifier: .iso8601)
        return calendar
    }
    
    var iso8601Formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.calendar = iso8601Calendar
        return formatter
    }
    
    var dayOfWeek: Int {
        let dayOfWeek = iso8601Calendar.component(.weekday, from: self) - 1
        return dayOfWeek == 0 ? 7 : dayOfWeek
    }
    
    var startOfDay: Date {
        return iso8601Calendar.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return iso8601Calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self.startOfDay)!
    }
    
    var dayOfWeekForArray: Int {
        return self.dayOfWeek - 1
    }
    
    var firstDayOfWeek: Date {
        return iso8601Calendar.date(byAdding: .day, value: -self.dayOfWeek + 1, to: self)!
    }
    
    var lastDayOfWeek: Date {
        return iso8601Calendar.date(byAdding: .day, value: 7 - self.dayOfWeek, to: self)!
    }
    
    var lastDayOfWeekOrToday: Date {
        let lastDayOfWeek = self.lastDayOfWeek
        return lastDayOfWeek > Date() ? Date() : lastDayOfWeek
    }

    var weekdays: [Date] {
        var dates: [Date] = []
        
        for day in 1...7 {
            dates.append(iso8601Calendar.date(byAdding: .day, value: -self.dayOfWeek + day, to: self)!)
        }
        
        return dates
    }
    
    func datesBetween(date: Date) -> [Date] {
        var dates: [Date] = []
        
        let components = iso8601Calendar.dateComponents([.day], from: self, to: date)
        let days = components.day!
        let startingDay = days > 0 ? self : date
        for index in 0...abs(days) {
            let date = iso8601Calendar.date(byAdding: .day, value: index, to: startingDay)!
            dates.append(date)
        }
        
        return dates
    }
    
    var weekOfYear: Int {
        return iso8601Calendar.component(.weekOfYear, from: self)
    }
    
    func isBehindOf(date: Date) -> Bool {
        let currentDate = iso8601Calendar.ordinality(of: .day, in: .era, for: self)!
        let comparedDate = iso8601Calendar.ordinality(of: .day, in: .era, for: date)!
        return currentDate < comparedDate
    }
    
    func isSameOf(date: Date) -> Bool {
        let currentDate = iso8601Calendar.ordinality(of: .day, in: .era, for: self)!
        let comparedDate = iso8601Calendar.ordinality(of: .day, in: .era, for: date)!
        return currentDate == comparedDate
    }
    
    func isAheadOf(date: Date) -> Bool {
        let currentDate = iso8601Calendar.ordinality(of: .day, in: .era, for: self)!
        let comparedDate = iso8601Calendar.ordinality(of: .day, in: .era, for: date)!
        return currentDate > comparedDate
    }
}
