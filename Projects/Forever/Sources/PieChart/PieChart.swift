//
//  PieChart.swift
//  Forever
//
//  Created by sam on 4.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import hCoreUI
import UIKit

public struct PieChartSlice {
    public var percent: CGFloat
    public var color: UIColor

    public init(percent: CGFloat, color: UIColor) {
        self.percent = percent
        self.color = color
    }
}

public struct PieChart {
    let slicesSignal: ReadWriteSignal<[PieChartSlice]>

    public init(slicesSignal: ReadWriteSignal<[PieChartSlice]>) {
        self.slicesSignal = slicesSignal
    }

    func percentToRadian(_ percent: CGFloat) -> CGFloat {
        // Because angle starts wtih X positive axis, add 270 degrees to rotate it to Y positive axis.
        var angle = 270 + percent * 360
        if angle >= 360 {
            angle -= 360
        }
        return angle * CGFloat.pi / 180.0
    }
}

extension PieChart: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        let bag = DisposeBag()

        let pieView = UIView()

        pieView.snp.makeConstraints { make in
            make.height.width.equalTo(215)
        }

        stackView.addArrangedSubview(pieView)

        let pieViewWidth: CGFloat = 100

        let path = UIBezierPath(arcCenter: pieView.center,
                                radius: pieViewWidth * 3 / 8,
                                startAngle: percentToRadian(0),
                                endAngle: percentToRadian(0.999999),
                                clockwise: true)

        let filledLayer = CAShapeLayer()
        filledLayer.path = path.cgPath
        filledLayer.fillColor = nil
        filledLayer.strokeColor = UIColor.brand(.primaryButtonBackgroundColor).cgColor
        filledLayer.lineWidth = pieViewWidth - 25
        filledLayer.strokeStart = 0
        filledLayer.strokeEnd = 1

        pieView.layer.addSublayer(filledLayer)

        let sliceLayer = CAShapeLayer()
        sliceLayer.path = path.cgPath
        sliceLayer.fillColor = nil
        sliceLayer.strokeColor = UIColor.white.cgColor
        sliceLayer.lineWidth = pieViewWidth - 25
        sliceLayer.strokeStart = 0
        sliceLayer.strokeEnd = 0

        pieView.layer.addSublayer(sliceLayer)

        var previousPercentage: CGFloat = 0

        let animation = CASpringAnimation(keyPath: "strokeEnd")
        animation.damping = 20
        animation.duration = animation.settlingDuration

        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false

        sliceLayer.add(animation, forKey: "stroke-animation")

        bag += combineLatest(slicesSignal.atOnce().plain().toVoid(), pieView.didLayoutSignal.toVoid()).onValue { _ in

            let slicePercentage = self.slicesSignal.value.reduce(0) { result, slice in
                result + slice.percent
            }

            let path = UIBezierPath(arcCenter: pieView.center,
                                    radius: pieViewWidth * 3 / 8,
                                    startAngle: self.percentToRadian(0),
                                    endAngle: self.percentToRadian(0.999999),
                                    clockwise: true)

            filledLayer.path = path.cgPath
            sliceLayer.path = path.cgPath

            animation.fromValue = sliceLayer.presentation()?.strokeEnd ?? previousPercentage
            animation.toValue = slicePercentage

            sliceLayer.removeAnimation(forKey: "stroke-animation")
            sliceLayer.add(animation, forKey: "stroke-animation")

            previousPercentage = slicePercentage
        }

        return (stackView, bag)
    }
}
