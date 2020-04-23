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
    @IBOutlet private var percentSlider: PercentSlider?
    
    private var currentScreen: Screen = .daily
    private var swipeTriggered: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        addGestureRecogniser()
        Goal.loadProjects()
        Task.loadProjects()
        Wish.loadProjects()
        updateSlider()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        collectionView?.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    @IBAction func segmentedControlIndexChanged(_ sender: Any) {
        moveToIndex(segmentedControl?.selectedSegmentIndex)
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
        let alert = UIAlertController(title: "Add new item", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add to Daily routine", style: .default, handler: { (action) in
            if let title = alert.textFields?.first?.text, title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                Task.allItems?.append(Task(title: title))
                (self.collectionView?.cellForItem(at: IndexPath(row: Screen.daily.index, section: 0)) as? CollectionViewCell)?.refresh()
                Task.saveProjects()
                self.moveToIndex(Screen.daily.index)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Add to Goals", style: .default, handler: { (action) in
            if let title = alert.textFields?.first?.text, title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                Goal.allItems?.append(Goal(title: title))
                (self.collectionView?.cellForItem(at: IndexPath(row: Screen.goals.index, section: 0)) as? CollectionViewCell)?.refresh()
                Goal.saveProjects()
                self.moveToIndex(Screen.goals.index)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Add to Wish list", style: .default, handler: { (action) in
            if let title = alert.textFields?.first?.text, title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                Wish.allItems?.append(Wish(title: title))
                (self.collectionView?.cellForItem(at: IndexPath(row: Screen.wish.index, section: 0)) as? CollectionViewCell)?.refresh()
                Wish.saveProjects()
                self.moveToIndex(Screen.wish.index)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: nil)
        
        present(alert, animated:  true)
    }
        
    private func moveToIndex(_ index: Int?) {
        guard let index = index, index >= 0, index < Screen.all.count else { return }
        segmentedControl?.selectedSegmentIndex = index
        collectionView?.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        currentScreen = Screen.all[index]
        updateSlider()
    }
    
    private func updateSlider() {
        let percent: CGFloat
        switch currentScreen {
        case .daily:
            percent = Task.donePercent
        case .goals:
            percent = Goal.donePercent
        case .wish:
            percent = Wish.donePercent
        }
        percentSlider?.update(with: percent)
    }
    
    private func addGestureRecogniser() {
        let rightRecogniser =  UIScreenEdgePanGestureRecognizer()
        rightRecogniser.addTarget(self, action: #selector(self.swipe(_:)))
        rightRecogniser.edges = .right
        let leftRecogniser =  UIScreenEdgePanGestureRecognizer()
        leftRecogniser.addTarget(self, action: #selector(self.swipe(_:)))
        leftRecogniser.edges = .left
        
        collectionView?.addGestureRecognizer(rightRecogniser)
        collectionView?.addGestureRecognizer(leftRecogniser)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.type = Screen.all[indexPath.row]
        cell.delegate = self
        return cell
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
                return "Daily routine"
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
    func collectionViewCell(_ cell: CollectionViewCell, didSelectRow state: Bool, atIndexPath indexPath: IndexPath) {
        updateSlider()
    }
}
