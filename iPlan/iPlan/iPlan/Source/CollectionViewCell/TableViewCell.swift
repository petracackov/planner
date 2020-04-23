//
//  TableViewCell.swift
//  iPlan
//
//  Created by Petra Čačkov on 06/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet private var cellView: UIView?
    @IBOutlet private var label: UILabel?
    
    
    var title: String? {
        didSet {
            label?.text = title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        cellView?.layer.cornerRadius = 10
        
        cellView?.layer.shadowColor = UIColor.systemGray.cgColor
        cellView?.layer.shadowOpacity = 0.7
        cellView?.layer.shadowOffset = .zero
        cellView?.layer.shadowRadius = 2
        
    }
    
}
