import Flow
import Foundation
import UIKit
import hCore
import hCoreUI

public struct PieChartState {
    public let percentagePerSlice: CGFloat
    public let slices: CGFloat

    public init(
        percentagePerSlice: CGFloat,
        slices: CGFloat
    ) {
        self.percentagePerSlice = percentagePerSlice
        self.slices = slices
    }

    public init(
        grossAmount: MonetaryAmount,
        netAmount: MonetaryAmount,
        potentialDiscountAmount: MonetaryAmount
    ) {
        let totalNeededSlices = grossAmount.value / potentialDiscountAmount.value
        slices = (CGFloat(grossAmount.value - netAmount.value) / CGFloat(potentialDiscountAmount.value))
        percentagePerSlice = 1 / CGFloat(totalNeededSlices)
    }
}

public struct PieChart {
    let stateSignal: ReadWriteSignal<PieChartState>
    let animated: Bool

    public init(
        stateSignal: ReadWriteSignal<PieChartState>,
        animated: Bool = true
    ) {
        self.stateSignal = stateSignal
        self.animated = animated
    }

    func percentToRadian(_ percent: CGFloat) -> CGFloat {
        var angle = 270 + percent * 360
        if angle >= 360 { angle -= 360 }
        return angle * CGFloat.pi / 180.0
    }
}

extension PieChart: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        let bag = DisposeBag()

        let pieView = UIView()

        pieView.snp.makeConstraints { make in make.height.width.equalTo(200) }

        stackView.addArrangedSubview(pieView)

        let pieViewWidth: CGFloat = 125

        let radius = pieViewWidth * 3 / 8

        let path = UIBezierPath(
            arcCenter: pieView.center,
            radius: radius,
            startAngle: percentToRadian(0),
            endAngle: percentToRadian(0.999_999),
            clockwise: true
        )

        let lineWidth = radius * 2

        let filledLayer = CAShapeLayer()
        filledLayer.path = path.cgPath
        filledLayer.fillColor = nil
        filledLayer.lineWidth = lineWidth - UIScreen.main.hairlineWidth
        filledLayer.strokeStart = 0
        filledLayer.strokeEnd = 1

        pieView.layer.addSublayer(filledLayer)

        let sliceLayer = CAShapeLayer()
        sliceLayer.path = path.cgPath
        sliceLayer.fillColor = nil
        sliceLayer.lineWidth = lineWidth
        sliceLayer.strokeStart = 0
        sliceLayer.strokeEnd = 0

        pieView.layer.addSublayer(sliceLayer)

        let nextSliceLayer = CAShapeLayer()
        nextSliceLayer.path = path.cgPath
        nextSliceLayer.fillColor = nil
        nextSliceLayer.lineWidth = lineWidth
        nextSliceLayer.strokeStart = 0
        nextSliceLayer.strokeEnd = 0

        pieView.layer.addSublayer(nextSliceLayer)

        bag += pieView.traitCollectionSignal.atOnce()
            .onValue { trait in
                filledLayer.strokeColor = UIColor(red: 1.00, green: 0.59, blue: 0.31, alpha: 1).cgColor

                if #available(iOS 13.0, *) {
                    if trait.userInterfaceLevel == .elevated {
                        sliceLayer.strokeColor = UIColor.brand(.primaryBackground()).cgColor
                    } else {
                        sliceLayer.strokeColor = UIColor.brand(.secondaryBackground()).cgColor
                    }
                } else {
                    sliceLayer.strokeColor = UIColor.brand(.secondaryBackground()).cgColor
                }

                if trait.userInterfaceStyle == .dark {
                    nextSliceLayer.strokeColor = UIColor.black.withAlphaComponent(0.4).cgColor
                } else {
                    nextSliceLayer.strokeColor =
                        UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.4).cgColor
                }
            }

        var previousPercentage: CGFloat = 0

        bag += combineLatest(stateSignal.atOnce().plain().toVoid(), pieView.didLayoutSignal.toVoid())
            .onValueDisposePrevious { _ in
                let slicePercentage =
                    self.stateSignal.value.percentagePerSlice * self.stateSignal.value.slices

                let path = UIBezierPath(
                    arcCenter: pieView.center,
                    radius: pieViewWidth * 3 / 8,
                    startAngle: self.percentToRadian(0),
                    endAngle: self.percentToRadian(0.999_999),
                    clockwise: true
                )

                filledLayer.path = path.cgPath
                sliceLayer.path = path.cgPath
                nextSliceLayer.path = path.cgPath

                let bag = DisposeBag()

                if self.animated {
                    let sliceAnimation = CASpringAnimation(keyPath: "strokeEnd")
                    sliceAnimation.damping = 20
                    sliceAnimation.duration = sliceAnimation.settlingDuration

                    sliceAnimation.fillMode = CAMediaTimingFillMode.forwards
                    sliceAnimation.isRemovedOnCompletion = false

                    sliceAnimation.fromValue =
                        sliceLayer.presentation()?.strokeEnd ?? previousPercentage
                    sliceAnimation.toValue = slicePercentage

                    sliceLayer.removeAnimation(forKey: "stroke-animation")
                    sliceLayer.add(sliceAnimation, forKey: "stroke-animation")

                    let nextSliceStrokeStartAnimation = CASpringAnimation(keyPath: "strokeStart")
                    nextSliceStrokeStartAnimation.damping = 50
                    nextSliceStrokeStartAnimation.duration =
                        nextSliceStrokeStartAnimation.settlingDuration

                    nextSliceStrokeStartAnimation.fillMode = CAMediaTimingFillMode.forwards
                    nextSliceStrokeStartAnimation.isRemovedOnCompletion = false

                    nextSliceStrokeStartAnimation.fromValue =
                        nextSliceLayer.presentation()?.strokeStart ?? 0
                    nextSliceStrokeStartAnimation.toValue = slicePercentage

                    nextSliceLayer.removeAnimation(forKey: "stroke-start-animation")
                    nextSliceLayer.add(
                        nextSliceStrokeStartAnimation,
                        forKey: "stroke-start-animation"
                    )

                    let nextSliceAnimation = CASpringAnimation(keyPath: "strokeEnd")
                    nextSliceAnimation.damping = 50
                    nextSliceAnimation.duration = nextSliceAnimation.settlingDuration

                    nextSliceAnimation.fillMode = CAMediaTimingFillMode.forwards
                    nextSliceAnimation.isRemovedOnCompletion = false

                    nextSliceAnimation.fromValue = nextSliceLayer.presentation()?.strokeEnd ?? 0
                    nextSliceAnimation.toValue = slicePercentage

                    nextSliceLayer.removeAnimation(forKey: "stroke-animation")
                    nextSliceLayer.add(nextSliceAnimation, forKey: "stroke-animation")

                    bag += Signal(after: sliceAnimation.settlingDuration * 0.6)
                        .onValue { _ in nextSliceLayer.opacity = 1

                            let nextSliceStrokeStartAnimation = CASpringAnimation(
                                keyPath: "strokeStart"
                            )
                            nextSliceStrokeStartAnimation.damping = 50
                            nextSliceStrokeStartAnimation.duration =
                                sliceAnimation.settlingDuration

                            nextSliceStrokeStartAnimation.fillMode =
                                CAMediaTimingFillMode.forwards
                            nextSliceStrokeStartAnimation.isRemovedOnCompletion = false

                            nextSliceStrokeStartAnimation.fromValue =
                                nextSliceLayer.presentation()?.strokeStart ?? 0
                            nextSliceStrokeStartAnimation.toValue = slicePercentage

                            nextSliceLayer.removeAnimation(forKey: "stroke-start-animation")
                            nextSliceLayer.add(
                                nextSliceStrokeStartAnimation,
                                forKey: "stroke-start-animation"
                            )

                            let nextSliceAnimation = CASpringAnimation(keyPath: "strokeEnd")
                            nextSliceAnimation.damping = 50
                            nextSliceAnimation.duration = sliceAnimation.settlingDuration

                            nextSliceAnimation.fillMode = CAMediaTimingFillMode.forwards
                            nextSliceAnimation.isRemovedOnCompletion = false

                            nextSliceAnimation.fromValue = 0
                            nextSliceAnimation.toValue =
                                slicePercentage
                                + self.stateSignal.value.percentagePerSlice

                            nextSliceLayer.removeAnimation(forKey: "stroke-animation")
                            nextSliceLayer.add(
                                nextSliceAnimation,
                                forKey: "stroke-animation"
                            )
                        }
                } else {
                    sliceLayer.strokeEnd = slicePercentage
                    nextSliceLayer.strokeStart = slicePercentage
                    nextSliceLayer.strokeEnd =
                        slicePercentage + self.stateSignal.value.percentagePerSlice
                }

                previousPercentage = slicePercentage

                return bag
            }

        return (stackView, bag)
    }
}
