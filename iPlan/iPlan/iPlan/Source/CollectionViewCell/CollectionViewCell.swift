//
//  CollectionViewCell.swift
//  iPlan
//
//  Created by Petra Čačkov on 06/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegate: class {
    func collectionViewCell(_ cell: CollectionViewCell, didSelectRow state: Bool, atIndexPath indexPath: IndexPath)
}

class CollectionViewCell: UICollectionViewCell {
    
    private var items: [Item]?
    
    weak var delegate: CollectionViewCellDelegate?
    
    var type: ViewController.Screen = .daily {
        didSet {
            refresh()
        }
    }
    
    @IBOutlet private var tableView: UITableView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        tableView?.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    func refresh() {
        switch type {
        case .daily:
            // TODO:
            //items = Task.allItems
            items = History.days?.last?.tasks
        case .goals:
            items = Goal.allItems
        case .wish:
            items = Wish.allItems
        }
        tableView?.reloadData()
    }
    
    private func save() {
        switch type {
        case .daily:
//            Task.allItems = items as? [Task]
//            Task.saveProjects()
            // TODO:
            if let tasks = items as? [Task] {
                History.days?.last?.tasks = tasks
                History.save()
            }
            
        case .goals:
            Goal.allItems = items as? [Goal]
            Goal.saveProjects()
        case .wish:
            Wish.allItems = items as? [Wish]
            Wish.saveProjects()
        }
    }
    
}

extension CollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let item = items?[indexPath.row]
        cell.title = item?.title
        cell.accessoryType = item?.isDone == true ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        items?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        save()
    }
       
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            items?[indexPath.row].isDone = false
            save()
            delegate?.collectionViewCell(self, didSelectRow: false, atIndexPath: indexPath)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            items?[indexPath.row].isDone = true
            save()
            delegate?.collectionViewCell(self, didSelectRow: true, atIndexPath: indexPath)
        }
    }
}
