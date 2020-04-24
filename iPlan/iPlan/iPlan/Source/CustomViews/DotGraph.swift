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

    var graphValues: [CGFloat] = [40, 25, 60, 40, 50, 80, 30]
    
    private var graphPoints: [(location: CGPoint, value: CGFloat)] = []
    
    @IBInspectable var topColor: UIColor = .white
    @IBInspectable var bottomColor: UIColor = .yellow
    @IBInspectable var lineColor: UIColor = .yellow
    @IBInspectable var hasBackgroundGradient: Bool = false
    @IBInspectable var pointDiameter: CGFloat = 5
    @IBInspectable var offset: CGFloat = 5
    
    private lazy var gradient: CGGradient? = {
        let colors = [topColor.cgColor, bottomColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        return CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
    }()
        
    override func draw(_ rect: CGRect) {
        graphPoints = generatePoints()
        let context = UIGraphicsGetCurrentContext()
        if let gradient = gradient, hasBackgroundGradient {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8))
            path.addClip()
            context?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: bounds.height), options: [])
        }
        
        drawGraph(in: rect, context: context)
        
    }
    
    private func generatePoints() -> [(location: CGPoint, value: CGFloat)] {
        let graphWidth = bounds.width - 2 * offset
        let graphHeight = bounds.height - 2 * offset
        
        var points: [(location: CGPoint, value: CGFloat)] = []
        for (index, value) in graphValues.enumerated() {
            let horizontalSpacing = graphWidth/CGFloat(self.graphValues.count-1)
            let verticalUnit = graphHeight/100
            points.append((CGPoint(x: horizontalSpacing * CGFloat(index) + offset, y: graphHeight + offset - verticalUnit * value ), value))
        }
        return points
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
        
        for index in 0..<graphPoints.count {
            var pointOrigin = graphPoints[index].location
            pointOrigin.x -= pointDiameter/2
            pointOrigin.y -= pointDiameter/2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: pointOrigin, size: CGSize(width: pointDiameter, height: pointDiameter)))
            circle.fill()
            
        }
    }
    
    private func drawLines() {
        let linePath = UIBezierPath()
        let lineVerticalSpace: CGFloat = (bounds.height - 2 * offset)/4
        linePath.move(to: CGPoint(x: offset, y: offset))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: offset))
        
        linePath.move(to: CGPoint(x: offset, y: offset + lineVerticalSpace))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: offset + lineVerticalSpace))
        
        linePath.move(to: CGPoint(x: offset, y: offset + lineVerticalSpace * 2))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: offset + lineVerticalSpace * 2))
        
        linePath.move(to: CGPoint(x: offset, y: offset + lineVerticalSpace * 3))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: offset + lineVerticalSpace * 3))
        
        linePath.move(to: CGPoint(x: offset, y: offset + lineVerticalSpace * 4))
        linePath.addLine(to: CGPoint(x: bounds.width - offset, y: offset + lineVerticalSpace * 4))
        
        topColor.withAlphaComponent(0.2).setStroke()
            
        linePath.lineWidth = 1.0
        linePath.stroke()
        
    }
}
