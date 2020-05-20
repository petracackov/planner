//
//  Task.swift
//  iPlan
//
//  Created by Petra Čačkov on 06/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class Task: Item {
    
    static var allItems: [Task]?
    
    static var donePercent: CGFloat {
        guard let allItems = allItems, allItems.isEmpty == false else { return 0 }
        let doneCount: CGFloat = CGFloat(allItems.filter { $0.isDone == true }.count)
        return doneCount/CGFloat(allItems.count)
    }
    
    func copy() -> Task {
        return Task(title: title, isDone: isDone, date: dateCreated)
    }
}
