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
        let gregorian = Calendar(identifier: .gregorian)
        guard let date = date else { return nil }
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    static func startOfTheWeekString(includingDate date: Date?) -> String? {
        return dateToDescriptor(date: startOfTheWeek(includingDate: date))
    }
    
    static func endOfTheWeek(includingDate date: Date?) -> Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let date = date else { return nil }
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    static func endOfTheWeekString(includingDate date: Date?) -> String? {
        return dateToDescriptor(date: endOfTheWeek(includingDate: date))
    }
}
