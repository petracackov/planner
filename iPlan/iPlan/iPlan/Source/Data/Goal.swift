//
//  Goal.swift
//  iPlan
//
//  Created by Petra Čačkov on 06/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class Goal: Item {
    
    static var allItems: [Goal]?
    
    static var donePercent: CGFloat {
        guard let allItems = allItems else { return 0 }
        let doneCount: CGFloat = CGFloat(allItems.filter { $0.isDone == true }.count)
        return doneCount/CGFloat(allItems.count)
    }
    
    private static var mainFilePath: String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        return documentsPath + "/Goals.iPlan"
    }
    
    static func loadProjects() {
        guard FileManager.default.fileExists(atPath: mainFilePath) else {
            allItems = [Goal]()
            return
        }
        guard let data = NSData(contentsOfFile: mainFilePath) else { return }

        do {
            guard let array = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: Any]] else { return }
            let goals = array.compactMap { Goal(descriptor: $0) }
            self.allItems = goals
        } catch {
            print(error)
            self.allItems = [Goal]()
        }
    }
    
    static func saveProjects() {
        guard let goals = allItems else { return }
        
        let descriptorArray: [[String: Any]] = goals.map { $0.descriptor }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: descriptorArray, options: .prettyPrinted)
            try? FileManager.default.removeItem(atPath: mainFilePath)
            FileManager.default.createFile(atPath: mainFilePath, contents: jsonData, attributes: nil)
        } catch {
            print(error)
        }
    }

}
