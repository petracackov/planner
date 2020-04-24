//
//  DotGraph.swift
//  iPlan
//
//  Created by Petra Čačkov on 23/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

@IBDesignable
class DotGraph: UIView {

    var graphValues: [CGFloat] = [40, 20, 60, 40, 50, 80, 30] {
        didSet {
            graphPoints = points()
        }
    }
    
    private var graphPoints: [(location: CGPoint, value: CGFloat)] = []
    
    @IBInspectable var topColor: UIColor = .white
    @IBInspectable var bottomColor: UIColor = .yellow
    @IBInspectable var lineColor: UIColor = .yellow
    @IBInspectable var hasBackgroundGradient: Bool = false
    @IBInspectable var pointDiameter: CGFloat = 5
    
    private lazy var gradient: CGGradient? = {
        let colors = [topColor.cgColor, bottomColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
    }()
        
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        if let gradient = gradient, hasBackgroundGradient {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8))
            path.addClip()
            context?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: bounds.height), options: [])
        }
        
        drawGraph(in: rect, context: context)
        
    }
    
    private func points() -> [(location: CGPoint, value: CGFloat)] {
        let offset: CGFloat = 5.0
        let graphWidth = bounds.width - 2 * offset
        let graphHeight = bounds.height - 2 * offset
        
        var points: [(location: CGPoint, value: CGFloat)] = []
        for (index, value) in graphPoints.enumerated() {
            let horizontalSpacing = graphWidth/CGFloat(self.graphPoints.count-1)
            let verticalUnit = graphHeight/100
            points.append((CGPoint(x: horizontalSpacing * CGFloat(index) + offset, y: graphHeight + offset - verticalUnit * value ), value))
        }
        return points
    }
    
    private func drawGraph(in rect: CGRect, context: CGContext?) {
        // graph
        let offset: CGFloat = 5.0
        let graphWidth = rect.width - 2 * offset
        let graphHeight = rect.height - 2 * offset
        let graphPoint = { (pointIndex: Int, pointValue: CGFloat) -> CGPoint in
            
            let horizontalSpacing = graphWidth/CGFloat(self.graphPoints.count-1)
            let verticalUnit = graphHeight/100
            return CGPoint(x: horizontalSpacing * CGFloat(pointIndex) + offset, y: graphHeight + offset - verticalUnit * pointValue )
            
        }
        
        lineColor.setFill()
        lineColor.setStroke()
        
        let graphPath = UIBezierPath()
        
        graphPath.move(to: graphPoint(0, graphPoints[0]) )
        
        for index in 0..<graphPoints.count {
            graphPath.addLine(to: graphPoint(index, graphPoints[index]))
        }
        context?.saveGState()
        // gradient
        let clippingPath = graphPath.copy() as? UIBezierPath
        clippingPath?.addLine(to: CGPoint(x: graphPoint(graphPoints.count - 1, graphPoints[graphPoints.count - 1]).x, y: rect.height))
        clippingPath?.addLine(to: CGPoint(x: graphPoint(0, graphPoints[0]).x, y: rect.height))
        clippingPath?.close()
        
        clippingPath?.addClip()
        
        if let gradient = gradient {
            context?.drawLinearGradient(gradient, start: CGPoint(x: offset, y: graphPoints.min() ?? 0), end: CGPoint(x: offset, y: rect.height), options: [])
        }
        
        context?.restoreGState()
        graphPath.lineWidth = 2
        graphPath.stroke()
        
        // points
        
        for index in 0..<graphPoints.count {
            var pointOrigin = graphPoint(index, graphPoints[index])
            pointOrigin.x -= pointDiameter/2
            pointOrigin.y -= pointDiameter/2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: pointOrigin, size: CGSize(width: pointDiameter, height: pointDiameter)))
            circle.fill()
            
        }
    }
}
