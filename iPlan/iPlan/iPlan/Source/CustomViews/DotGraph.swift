//
//  DotGraph.swift
//  iPlan
//
//  Created by Petra Čačkov on 23/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

protocol DotGraphDelegate: class {
    func dotGraph(_ graph: DotGraph, didSelectDot dotIndex: Int)
}

@IBDesignable
class DotGraph: UIView {

    
    var graphValuesInPercents: [CGFloat] = [0.4, 0.25, 0.60, 0.40, 0.50, 0.80, 0.30] {
        didSet {
            setNeedsDisplay()
        }
    }
    var xAxesValues: [String] = ["M","T","W","T","F","S","S"] {
        didSet {
            addXAxesLabels()
        }
    }
    
    weak var delegate: DotGraphDelegate?
    private(set) var selectedPointIndex: Int = 0
    
    private var graphPoints: [(location: CGPoint, value: CGFloat)] = []
    private var graphPointsViews: [UIView] = []
    private var xAxesLabels: [UILabel] = []
    
    @IBInspectable var maxNumberOfValues: Int = 1
    @IBInspectable var topColor: UIColor = .white
    @IBInspectable var bottomColor: UIColor = .yellow
    @IBInspectable var lineColor: UIColor = .yellow
    @IBInspectable var selectedColor: UIColor = .yellow
    @IBInspectable var hasBackgroundGradient: Bool = false
    @IBInspectable var pointDiameter: CGFloat = 5
    @IBInspectable var offset: CGFloat = 5
    @IBInspectable var labelSize: CGFloat = 12
    
    
    private lazy var gradient: CGGradient? = {
        let colors = [topColor.cgColor, bottomColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addXAxesLabels()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapGesture(_:))))
    }
    
    private var currentFrame: CGRect = .zero
    override func layoutSubviews() {
        super.layoutSubviews()
        if frame != currentFrame {
            addXAxesLabels()
            currentFrame = frame
        }
    }
    
    override func draw(_ rect: CGRect) {
        graphPoints = generatePoints()
        addPoints()
        let context = UIGraphicsGetCurrentContext()
        if let gradient = gradient, hasBackgroundGradient {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8))
            path.addClip()
            context?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: bounds.height), options: [])
        }
        
        drawGraph(in: rect, context: context)
        
    }
    
    @objc private func onTapGesture(_ sender: UITapGestureRecognizer) {
        
        for (index, pointView) in graphPointsViews.enumerated() {
            let location = sender.location(in: pointView)
            if pointView.bounds.contains(location) {
                delegate?.dotGraph(self, didSelectDot: index)
            }
        }
    }
    
    private func addXAxesLabels() {
        xAxesLabels.forEach { $0.removeFromSuperview() }
        let horizontalSpace = (bounds.width - 2 * offset)/CGFloat(xAxesLabels.count-1)
        let yLocation = self.bounds.height - labelSize
        var labels: [UILabel] = []
        for (index, value) in xAxesValues.enumerated() {
            let label = UILabel()
            label.font = label.font.withSize(labelSize)
            label.text = value
            label.sizeToFit()
            label.frame.origin = CGPoint(x: offset + CGFloat(index) * horizontalSpace - label.bounds.width/2, y: yLocation)
            labels.append(label)
            self.addSubview(label)
        }
        xAxesLabels = labels
    }
    
    private func generatePoints() -> [(location: CGPoint, value: CGFloat)] {
        let graphWidth = bounds.width - 2 * offset
        let graphHeight = bounds.height - 2 * offset - labelSize
        
        var points: [(location: CGPoint, value: CGFloat)] = []
        for (index, value) in graphValuesInPercents.enumerated() {
            let horizontalSpacing = graphWidth/CGFloat(self.maxNumberOfValues - 1)
            points.append((CGPoint(x: horizontalSpacing * CGFloat(index) + offset, y: graphHeight + offset - graphHeight * value ), value))
        }
        return points
    }
    
    private func addPoints() {
        graphPointsViews.forEach { $0.removeFromSuperview() }
        
        var views: [UIView] = []
        for (index, point) in graphPoints.enumerated() {

            let pointContainerView = UIView()
            pointContainerView.backgroundColor = .clear
            pointContainerView.frame.size = CGSize(width: pointDiameter * 2, height: pointDiameter * 2)
            pointContainerView.layer.cornerRadius = pointContainerView.bounds.width/2
            pointContainerView.center = point.location
            pointContainerView.backgroundColor = index == selectedPointIndex ? selectedColor : .clear

            let pointView = UIView()
            pointView.backgroundColor = lineColor
            pointView.frame.size = CGSize(width: pointDiameter, height: pointDiameter)
            pointView.layer.cornerRadius = pointView.bounds.width/2
            pointView.center = CGPoint(x: pointContainerView.bounds.width/2, y: pointContainerView.bounds.height/2)

            pointContainerView.addSubview(pointView)
            views.append(pointContainerView)
            self.addSubview(pointContainerView)
        }
        graphPointsViews = views
    }
    
    private func drawGraph(in rect: CGRect, context: CGContext?) {
        // graph
        lineColor.setFill()
        lineColor.setStroke()
        
        let graphPath = UIBezierPath()
        
        graphPath.move(to: graphPoints[0].location )
        
        for index in 0..<graphPoints.count {
            graphPath.addLine(to: graphPoints[index].location)
        }
        context?.saveGState()
        // gradient
        let clippingPath = graphPath.copy() as? UIBezierPath
        clippingPath?.addLine(to: CGPoint(x: graphPoints[graphPoints.count - 1].location.x, y: rect.height))
        clippingPath?.addLine(to: CGPoint(x: graphPoints[0].location.x, y: rect.height))
        clippingPath?.close()
        
        clippingPath?.addClip()
        
        if let gradient = gradient {
            context?.drawLinearGradient(gradient, start: CGPoint(x: offset, y: graphPoints.map({ $0.location.y }).min() ?? 0), end: CGPoint(x: offset, y: rect.height), options: [])
        }
        
        context?.restoreGState()
        graphPath.lineWidth = 2
        graphPath.stroke()
        
        drawLines()
        
        // points
        
//        for index in 0..<graphPoints.count {
//            var pointOrigin = graphPoints[index].location
//            pointOrigin.x -= pointDiameter/2
//            pointOrigin.y -= pointDiameter/2
//
//            let circle = UIBezierPath(ovalIn: CGRect(origin: pointOrigin, size: CGSize(width: pointDiameter, height: pointDiameter)))
//            circle.fill()
//        }
    }
    
    private func drawLines() {
        let linePath = UIBezierPath()
        let lineVerticalSpace: CGFloat = (bounds.height - 2 * offset - labelSize)/4
        let topOffset: CGFloat = offset /* + labelSize*/
        linePath.move(to: CGPoint(x: offset, y: topOffset))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: topOffset))
        
        linePath.move(to: CGPoint(x: offset, y: topOffset + lineVerticalSpace))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: topOffset + lineVerticalSpace))
        
        linePath.move(to: CGPoint(x: offset, y: topOffset + lineVerticalSpace * 2))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: topOffset + lineVerticalSpace * 2))
        
        linePath.move(to: CGPoint(x: offset, y: topOffset + lineVerticalSpace * 3))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: topOffset + lineVerticalSpace * 3))
        
        linePath.move(to: CGPoint(x: offset, y: topOffset + lineVerticalSpace * 4))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: topOffset + lineVerticalSpace * 4))
        
        topColor.withAlphaComponent(0.2).setStroke()
            
        linePath.lineWidth = 1.0
        linePath.stroke()
        
    }
    
    
    func selectDot(atIndex index: Int) {
        guard index <= maxNumberOfValues else { return }
        selectedPointIndex = index
        setNeedsDisplay()
    }
}
