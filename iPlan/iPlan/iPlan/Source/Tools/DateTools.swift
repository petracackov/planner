//
//  DateTools.swift
//  iPlan
//
//  Created by Petra Čačkov on 26/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class DateTools {

    static func dateToDescriptor(date: Date?) -> String? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    static func dateFromString(date: String?) -> Date? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: date)
    }
    
    static func startOfTheDay(date: Date?) -> Date? {
        guard let date = date else { return nil }
        return Calendar.current.startOfDay(for: date)
    }
    
    static func startOfTheWeek(includingDate date: Date?) -> Date? {
        guard let date = date else { return nil }
        var calendar = Calendar.autoupdatingCurrent
        calendar.firstWeekday = 2
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }
    
    static func startOfTheWeekString(includingDate date: Date?) -> String? {
        return dateToDescriptor(date: startOfTheWeek(includingDate: date))
    }
    
    static func endOfTheWeek(includingDate date: Date?) -> Date? {
        guard let startOfTheWeek = startOfTheWeek(includingDate: date) else { return nil }
        return Calendar.current.date(byAdding: .day, value: 6, to: startOfTheWeek)
    }
    
    static func endOfTheWeekString(includingDate date: Date?) -> String? {
        return dateToDescriptor(date: endOfTheWeek(includingDate: date))
    }
}
