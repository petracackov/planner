//
//  History.swift
//  iPlan
//
//  Created by Petra Čačkov on 26/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class History {
    
    static var days: [Day]?
    
    private static var mainFilePath: String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        return documentsPath + "/History.iPlan"
    }
    
    static func loadDays() {
        guard FileManager.default.fileExists(atPath: mainFilePath) else {
            days = [Day(date: Date())]
            return
        }
        guard let data = NSData(contentsOfFile: mainFilePath) else { return }

        do {
            guard let array = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: Any]] else { return }
            
            var days: [Day] = array.compactMap { Day(descriptor: $0) }
            
            if days.last?.date != DateTools.startOfTheDay(date: Date()) {
                let tasks = days.last?.tasks.compactMap { return  $0.copy() } ?? []
                tasks.forEach { $0.isDone = false }
                days.append(Day(date: Date(), tasks: tasks))
            }
            
            if let startOfTheFirstWeek = DateTools.startOfTheWeek(includingDate: days.first?.date), startOfTheFirstWeek !=  days.first?.date {
                days.insert(Day(date: startOfTheFirstWeek), at: 0)
            }
            
            History.days = allDays(days: days)
        } catch {
            print(error)
            self.days = [Day]()
        }
    }
    
    static func save() {
        guard let days = days else { return }
        
        let descriptorArray: [[String: Any]] = days.map { $0.descriptor }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: descriptorArray, options: .prettyPrinted)
            try? FileManager.default.removeItem(atPath: mainFilePath)
            FileManager.default.createFile(atPath: mainFilePath, contents: jsonData, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    static private func allDays(days: [Day]) -> [Day] {
        let sortedDays: [Day] = days.sorted(by: { $0.date < $1.date })
        var allDays: [Day] = []
        
        for (index, value) in sortedDays.enumerated() {
            let day = value
            allDays.append(day)
            guard index < sortedDays.count - 1 else { break }
            let nextSavedDay = sortedDays[index+1].date
            guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: day.date) else { continue }
            let interval = Calendar.current.dateComponents([.day], from: nextDay, to: nextSavedDay).day ?? 0
            guard interval >= 1 else { continue }
            for dayDifference in 1...interval {
                if let computedDate = Calendar.current.date(byAdding: .day, value: dayDifference, to: day.date) {
                    allDays.append(Day(date: computedDate, tasks: day.tasks))
                }
            }
        }
        return allDays
    }
    
    static func daysInTheSameWeekAs(_ day: Day?) -> [Day]? {
        guard let day = day else { return nil }
        guard let historyDays = History.days else { return nil }
        var calendar =  Calendar.current
        calendar.firstWeekday = 2
        return historyDays.filter { calendar.isDate(day.date, equalTo: $0.date, toGranularity:  .weekOfYear) }
    }
    
}

// MARK: - Mocked data:

extension History {
    
    static func addMockData() {
        let days = ["01.03.2020", "10.03.2020", "01.04.2020", "20.04.2020", "25.03.2020", "20.02.2020"].map { Day(date: DateTools.dateFromString(date: $0) ?? Date(), tasks: generateRandomTasks())}
        History.days = days
        History.save()
    }
    
    static func cleanMockedData() {
        History.days = []
        History.save()
    }
    
    static private func generateRandomTasks() -> [Task] {
        let randomNumber = Int.random(in: 1...10)
        var tasks: [Task] = []
        for number in 0...randomNumber {
            let randomState = Int.random(in: 0...1)
            let randomDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0...60), to: Date() ) ?? Date()
            tasks.append(Task(title: String(describing: number), isDone: randomState == 0 ? false : true, date: randomDate))
        }
        return tasks
    }
}
