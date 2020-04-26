//
//  Day.swift
//  iPlan
//
//  Created by Petra Čačkov on 24/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class Day {
    
    let date: Date
    var tasks: [Task]?
    
    init(date: Date, tasks: [Task]? = nil) {
        self.date = date
    }
    
    convenience init?(descriptor: [String : Any]) {
        guard let date = DateTools.dateFromString(date: descriptor["date"] as? String) else { return nil }
        self.init(date: date)
        self.tasks = (descriptor["tasks"] as? [[String : Any]])?.compactMap { Task(descriptor: $0) }
    }
    
    var descriptor: [String: Any] {
        var descriptor: [String: Any] = [String: Any]()
        descriptor["tasks"] = tasks?.compactMap { $0.descriptor }
        descriptor["date"] = DateTools.dateToDescriptor(date: date)
        return descriptor
    }
}

