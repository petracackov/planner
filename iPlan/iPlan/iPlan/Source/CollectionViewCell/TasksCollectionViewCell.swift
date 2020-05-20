//
//  TasksCollectionViewCell.swift
//  iPlan
//
//  Created by Petra Čačkov on 20/05/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

protocol TasksCollectionViewCellDelegate: class {
    func tasksCollectionViewCell(_ cell: TasksCollectionViewCell, didChangeDay day: Day)
}

class TasksCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var tableView: UITableView?
    
    weak var delegate: TasksCollectionViewCellDelegate?
    
    var day: Day! {
        didSet {
            tableView?.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
}

extension TasksCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return day.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let task = day.tasks[indexPath.row]
        cell.title = task.title
        cell.accessoryType = task.isDone == true ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        day.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        day.save()
        delegate?.tasksCollectionViewCell(self, didChangeDay: day)
    }
       
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            day.tasks[indexPath.row].isDone = false
            day.save()
            delegate?.tasksCollectionViewCell(self, didChangeDay: day)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            day.tasks[indexPath.row].isDone = true
            day.save()
            delegate?.tasksCollectionViewCell(self, didChangeDay: day)
        }
    }
}
