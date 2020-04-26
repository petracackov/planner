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

}
