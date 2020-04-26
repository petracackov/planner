//
//  TestViewController.swift
//  iPlan
//
//  Created by Petra Čačkov on 26/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet var label: UILabel!
    
    var days: [Day]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        History.cleanMockedData()
        History.addMockData()
        setupData()
        
    }
    
    private func setupData() {
        History.loadDays()
        print(History.days?.last)
        days = History.days
        let datesLabel = days?.compactMap { DateTools.dateToDescriptor(date: $0.date) }.joined(separator: ", ")
        label.text = datesLabel
    }
    
}
