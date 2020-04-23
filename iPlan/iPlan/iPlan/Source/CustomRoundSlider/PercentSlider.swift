//
//  PercentSlider.swift
//  iPlan
//
//  Created by Petra Čačkov on 07/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit

class PercentSlider: UIView {
    
    private let lineThickness: CGFloat = 20
    private let circleLayer: CAShapeLayer = CAShapeLayer()
    private let arcLayer: CAShapeLayer = CAShapeLayer()
    private let arcColor =  UIColor(displayP3Red: 247/255, green: 233/255, blue: 102/255, alpha: 1)
    private let percentLabel: UILabel = UILabel()
    private var radius: CGFloat { min(bounds.width, bounds.height)/2 - lineThickness/2}
    private var previousValue: CGFloat = 0

        
    override func awakeFromNib() {
        super.awakeFromNib()
        addLayers()
        addPercentLabel()
    }
        
    private func addLayers() {
        
        // Just in case it is called several times
        arcLayer.removeFromSuperlayer()
        circleLayer.removeFromSuperlayer()
        
        let path =  UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2), radius: radius, startAngle: -.pi/2, endAngle: 3 * .pi/2, clockwise: true).cgPath
        arcLayer.path = path
        arcLayer.strokeColor = arcColor.cgColor
        arcLayer.lineWidth = lineThickness - 2
        arcLayer.lineCap = .round
        arcLayer.fillColor = nil
        arcLayer.strokeEnd = 0
        
        circleLayer.path = path
        circleLayer.strokeColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        circleLayer.lineWidth = lineThickness
        circleLayer.fillColor = nil
        
        layer.addSublayer(circleLayer)
        layer.addSublayer(arcLayer)
    }
    
    private func addPercentLabel() {
        percentLabel.removeFromSuperview()
        
        percentLabel.textAlignment = .center
        percentLabel.font = percentLabel.font.withSize(25)
        percentLabel.text = "0 %"
        percentLabel.frame = CGRect(origin: .zero, size: self.bounds.size)
        self.addSubview(percentLabel)
    }
    
    func update(with percent: CGFloat) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = previousValue
        animation.toValue = percent == 0 ? 0.001 : percent
        animation.duration = 0.3
        // So that animation stops at the end
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
    
        arcLayer.add(animation, forKey: "arc")

        percentLabel.text = String(describing: (percent * 1000).rounded() / 10) + " %"
        previousValue = percent
    }
    
}
