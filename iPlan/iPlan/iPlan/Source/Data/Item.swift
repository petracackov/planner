//
//  Item.swift
//  iPlan
//
//  Created by Petra Čačkov on 07/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class Item {


    var title: String
    var isDone: Bool?
    var dateCreated: Date
    
    init(title: String, isDone: Bool? = false, date: Date = Date()) {
        self.title = title
        self.isDone = isDone
        self.dateCreated = date
    }
    
    convenience init?(descriptor: [String : Any]) {
        guard let title = descriptor["title"] as? String else { return nil }
        let isDone =  descriptor["isDone"] as? Bool
        let date = Item.dateFromString(date: descriptor["date"] as? String) ?? Date()
        self.init(title: title, isDone: isDone, date: date)
    }
    
    var descriptor: [String: Any] {
        var descriptor: [String: Any] = [String: Any]()
        descriptor["title"] = title
        descriptor["isDone"] = isDone
        descriptor["date"] = dateToDescriptor(date: dateCreated)
        return descriptor
    }
    
    private func dateToDescriptor(date: Date?) -> String? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy hh:mm:ss"
        return formatter.string(from: date)
    }
    
    private static func dateFromString(date: String?) -> Date? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy hh:mm:ss"
        return formatter.date(from: date)
    }
    
}
