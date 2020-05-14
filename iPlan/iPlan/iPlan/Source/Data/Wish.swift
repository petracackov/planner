//
//  Wish.swift
//  iPlan
//
//  Created by Petra Čačkov on 06/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class Wish: Item {

    static var allItems: [Wish]?
    
    static var donePercent: CGFloat {
        guard let allItems = allItems, allItems.isEmpty == false else { return 0 }
        let doneCount: CGFloat = CGFloat(allItems.filter { $0.isDone == true }.count)
        return doneCount/CGFloat(allItems.count)
    }
    
    private static var mainFilePath: String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        return documentsPath + "/Wishes.iPlan"
    }
    
    static func loadProjects() {
        guard FileManager.default.fileExists(atPath: mainFilePath) else {
            allItems = [Wish]()
            return
        }
        guard let data = NSData(contentsOfFile: mainFilePath) else { return }

        do {
            guard let array = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: Any]] else { return }
            let wishes = array.compactMap { Wish(descriptor: $0) }
            self.allItems = wishes
        } catch {
            print(error)
            self.allItems = [Wish]()
        }
    }
    
    static func saveProjects() {
        guard let wishes = allItems else { return }
        
        let descriptorArray: [[String: Any]] = wishes.map { $0.descriptor }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: descriptorArray, options: .prettyPrinted)
            try? FileManager.default.removeItem(atPath: mainFilePath)
            FileManager.default.createFile(atPath: mainFilePath, contents: jsonData, attributes: nil)
        } catch {
            print(error)
        }
    }

}
