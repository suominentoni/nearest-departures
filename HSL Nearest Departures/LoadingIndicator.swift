//
//  LoadingIndicator.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 11/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import UIKit

open class LoadingIndicator: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        animateLoadingCircle()
    }

    required  public init?(coder aDecoder: NSCoder) {
        fatalError("Not coder compliant")
    }

    fileprivate func animateLoadingCircle() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = bounds
        rectShape.position = CGPoint(x: center.x, y: center.y)
        rectShape.path = UIBezierPath(ovalIn: rectShape.bounds).cgPath
        rectShape.lineWidth = 4.0
        rectShape.strokeColor = UIColor.lightGray.cgColor
        rectShape.fillColor = UIColor.clear.cgColor
        rectShape.strokeStart = 0
        rectShape.strokeEnd = 0.0

        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.duration = 2
        end.fromValue = 0
        end.toValue = 1.0
        end.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        let start = CABasicAnimation(keyPath: "strokeStart")
        start.beginTime = 0.5
        start.duration = 1.5
        start.fromValue = 0
        start.toValue = 1.0
        start.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        let group = CAAnimationGroup()
        group.duration = 2
        group.animations = [end, start]
        group.repeatCount = HUGE

        rectShape.add(group, forKey: nil)
        layer.addSublayer(rectShape)
    }
}
