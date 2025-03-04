//
//  ViewController.swift
//  iPlan
//
//  Created by Petra Čačkov on 06/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView?
    @IBOutlet private var segmentedControl: UISegmentedControl?
    @IBOutlet private var statsContainer: UIView?
    @IBOutlet private var percentSlider: PercentSlider?
    @IBOutlet private var dotGraph: DotGraph?
    @IBOutlet private var dotGraphContentView: UIStackView?
    @IBOutlet private var previousWeekButton: UIButton?
    @IBOutlet private var nextWeekButton: UIButton?
    
    private var currentScreen: Screen = .daily
    private var currentDay: Day?
    private var currentDayIndex: Int = 0 {
        didSet {
            guard currentDayIndex < History.days?.count ?? 0, let day = History.days?[currentDayIndex] else { return }
            currentDay = day
        }
    }
    private var swipeTriggered: Bool = false
    private var isDotGraphShowing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        addGestureRecognisers()
        Goal.loadProjects()
        Wish.loadProjects()
        History.loadDays()
        
        currentDayIndex = (History.days?.count ?? 1) - 1
        dotGraph?.maxNumberOfValues = 7
        dotGraph?.delegate = self
        nextWeekButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        previousWeekButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        collectionView?.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView?.register(UINib(nibName: "TasksCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TasksCollectionViewCell")
        
        reload()
    }
    
    @IBAction private func segmentedControlIndexChanged(_ sender: Any) {
        moveToIndex(segmentedControl?.selectedSegmentIndex)
    }
    
    @IBAction func goToPreviousWeek(_ sender: Any) {
        guard let currentDayGraphIndex = dotGraph?.selectedPointIndex else { return }
        let previousWeekIndex = currentDayIndex - currentDayGraphIndex - 1
        guard previousWeekIndex >= 0 else { return }
        currentDayIndex = previousWeekIndex
        reload()
    }
    @IBAction func goToNextWeek(_ sender: Any) {
        guard let currentDayGraphIndex = dotGraph?.selectedPointIndex else { return }
        let nextWeekIndex = currentDayIndex + 7 - currentDayGraphIndex
        guard nextWeekIndex <= History.days?.count ?? 1 - 1 else { return }
        currentDayIndex = nextWeekIndex
        reload()
    }
    
    private func reload() {
        let startOfTheWeek = DateTools.startOfTheWeekString(includingDate: currentDay?.date)
        let endOfTheWeek = DateTools.endOfTheWeekString(includingDate: currentDay?.date)
        nextWeekButton?.setTitle(endOfTheWeek, for: .normal)
        previousWeekButton?.setTitle(startOfTheWeek, for: .normal)
        updateSlider()
        updateDotGraph()
        dotGraph?.selectDot(atIndex: currentDayIndex % 7)
        collectionView?.reloadData()
    }
    
    @objc private func switchGraph(_ sender: UISwipeGestureRecognizer?) {
        switchGraph(direction: sender?.direction)
    }
    
    @objc private func swipe(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard let currentlySelectedIndex = segmentedControl?.selectedSegmentIndex else { return }
        
        switch sender.state {
        case .began, .changed:
            guard swipeTriggered == false else { return }
            
            let threshold: CGFloat = 10
            let translation = abs(sender.translation(in: view).x)
            if translation >= threshold  {
                switch sender.edges {
                case .right:
                    guard currentlySelectedIndex < Screen.all.count - 1 else { return }
                    moveToIndex(currentlySelectedIndex + 1)
                case .left:
                    guard currentlySelectedIndex > 0 else { return }
                    moveToIndex(currentlySelectedIndex - 1)
                default:
                    return
                }
                swipeTriggered = true
            }
        case .ended, .failed, .cancelled, .possible:
            swipeTriggered = false
        @unknown default:
            break
        }
    }
        
    @objc func addItem() {
        let alert: UIAlertController
        switch currentScreen {
        case .daily:
             alert = UIAlertController(title: "Add new Task", message: nil, preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
                 if let title = alert.textFields?.first?.text, title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                     self?.currentDay?.tasks.append(Task(title: title))
                     //(self.collectionView?.cellForItem(at: IndexPath(row: Screen.daily.index, section: 0)) as? TasksCollectionViewCell)?.refresh()
                     History.save()
                    self?.reload()
                 }
             }))
        case .goals:
             alert = UIAlertController(title: "Add new Goal", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
                if let title = alert.textFields?.first?.text, title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                    Goal.allItems?.append(Goal(title: title))
                    //(self.collectionView?.cellForItem(at: IndexPath(row: Screen.goals.index, section: 0)) as? CollectionViewCell)?.refresh()
                    Goal.saveProjects()
                    self?.reload()
                }
            }))
        case .wish:
            alert = UIAlertController(title: "Add new Wish", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
                if let title = alert.textFields?.first?.text, title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                    Wish.allItems?.append(Wish(title: title))
                    //(self.collectionView?.cellForItem(at: IndexPath(row: Screen.wish.index, section: 0)) as? CollectionViewCell)?.refresh()
                    Wish.saveProjects()
                    self?.reload()
                }
            }))
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: nil)
        
        present(alert, animated:  true)
    }
        
    private func switchGraph(direction: UISwipeGestureRecognizer.Direction?) {
        guard currentScreen == .daily else { return }
        guard let dotGraphContentView = dotGraphContentView, let percentSlider = percentSlider else { return }
        let transitionDirection: UIView.AnimationOptions  = direction == .right ? .transitionFlipFromLeft : .transitionFlipFromRight
        if isDotGraphShowing {
            UIView.transition(from: dotGraphContentView, to: percentSlider, duration: 1, options: [transitionDirection, .showHideTransitionViews], completion: nil)
        } else {
            UIView.transition(from: percentSlider, to: dotGraphContentView, duration: 1, options: [transitionDirection, .showHideTransitionViews], completion: nil)
        }
        
        isDotGraphShowing = !isDotGraphShowing
    }
    
    private func moveToIndex(_ index: Int?) {
        guard let index = index, index >= 0, index < Screen.all.count else { return }
        if isDotGraphShowing { switchGraph(direction: .right)}
        segmentedControl?.selectedSegmentIndex = index
        collectionView?.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        currentScreen = Screen.all[index]
        updateSlider()
    }
    
    private func updateSlider() {
        let percent: CGFloat
        switch currentScreen {
        case .daily:
            percent = currentDay?.donePercent ?? 0
        case .goals:
            percent = Goal.donePercent
        case .wish:
            percent = Wish.donePercent
        }
        percentSlider?.update(with: percent)
    }
    
    private func updateDotGraph() {
        guard let currentWeekDays = History.daysInTheSameWeekAs(currentDay) else { return }
        dotGraph?.graphValuesInPercents = currentWeekDays.map { $0.donePercent }
    }
    
    private func addGestureRecognisers() {
        let rightRecogniser =  UIScreenEdgePanGestureRecognizer()
        rightRecogniser.addTarget(self, action: #selector(self.swipe(_:)))
        rightRecogniser.edges = .right
        let leftRecogniser =  UIScreenEdgePanGestureRecognizer()
        leftRecogniser.addTarget(self, action: #selector(self.swipe(_:)))
        leftRecogniser.edges = .left
        
        collectionView?.addGestureRecognizer(rightRecogniser)
        collectionView?.addGestureRecognizer(leftRecogniser)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(switchGraph(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(switchGraph(_:)))
        swipeRight.direction = .right
        
        statsContainer?.addGestureRecognizer(swipeRight)
        statsContainer?.addGestureRecognizer(swipeLeft)
    }
    
    private func setupSegmentedControl() {
        segmentedControl?.removeAllSegments()
        
        for index in 0..<Screen.all.count {
            let segment = Screen.all[index].title
            segmentedControl?.insertSegment(withTitle: segment, at: index, animated: false)
        }
        moveToIndex(0)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Screen.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = Screen.all[indexPath.row]
        switch type {
        case .goals, .wish:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            cell.type = type
            cell.delegate = self
            return cell
        case .daily:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TasksCollectionViewCell", for: indexPath) as! TasksCollectionViewCell
            cell.day = currentDay
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}

extension ViewController {
    
    enum Screen {
        case goals
        case daily
        case wish
        
        static let all: [Screen] = [.daily, .goals, .wish]
    
        var index: Int {
            Screen.all.firstIndex(of: self) ?? 0
        }
        
        var title: String {
            switch self {
            case .daily:
                return "Daily tasks"
            case .goals:
                return "Goals"
            case .wish:
                return "Wish list"
            }
        }
    }
}

// MARK: - CollectionViewCellDelegate

extension ViewController: CollectionViewCellDelegate {
    func collectionViewCell(_ cell: CollectionViewCell, didSelectRow state: Bool, atIndexPath indexPath: IndexPath?) {
        updateSlider()
    }
}

// MARK: - TasksCollectionViewCellDelegate
extension ViewController: TasksCollectionViewCellDelegate {
    func tasksCollectionViewCell(_ cell: TasksCollectionViewCell, didChangeDay day: Day) {
        currentDay = day
        updateSlider()
        updateDotGraph()
    }
}

// MARK: - DotGraphDelegate

extension ViewController: DotGraphDelegate {
    func dotGraph(_ graph: DotGraph, didSelectDot dotIndex: Int) {
        let difference = dotIndex - graph.selectedPointIndex
        currentDayIndex += difference
        reload()
    }
}
