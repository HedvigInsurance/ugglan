//
//  Tooltip.swift
//  hCoreUI
//
//  Created by sam on 14.9.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import Presentation
import UIKit

public struct Tooltip {
    var sourceRect: CGRect

    init(sourceRect: CGRect) {
        self.sourceRect = sourceRect
    }
}

class TriangleView: UIView {
    let color: UIColor

    init(frame: CGRect, color: UIColor) {
        self.color = color
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_: UITraitCollection?) {
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX / 2.0, y: rect.minY))
        context.closePath()

        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}

extension UIView {
    public func present(_ tooltip: Tooltip) -> Disposable {
        let bag = DisposeBag()
        let tooltipView = tooltip.materialize(into: bag)
        tooltipView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).concatenating(CGAffineTransform(translationX: 0, y: -20))

        addSubview(tooltipView)

        tooltipView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).offset(14)
            make.right.equalTo(self.snp.right)
        }

        bag += tooltipView.hasWindowSignal.atOnce().filter(predicate: { $0 }).take(first: 1).toVoid().animated(style: .heavyBounce()) {
            tooltipView.transform = .identity
        }

        let tapGesture = UITapGestureRecognizer()
        // bag += self.viewController?.view.install(tapGesture)

        bag += tapGesture.signal(forState: .began).onValue { _ in
            tooltipView.removeFromSuperview()
            bag.dispose()
        }

        bag += Signal(after: 60).animated(style: .heavyBounce()) {
            tooltipView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).concatenating(CGAffineTransform(translationX: 0, y: -20))
            tooltipView.alpha = 0
        }

        return bag
    }
}

extension Tooltip: Presentable {
    public func materialize() -> (UIView, Disposable) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .brand(.link)
        backgroundView.layer.cornerRadius = .defaultCornerRadius

        let triangleView = TriangleView(frame: .zero, color: .brand(.link))
        backgroundView.addSubview(triangleView)

        triangleView.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.width.equalTo(16)
            make.right.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(-6)
        }

        let bag = DisposeBag()

        let contentContainer = UIStackView()
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.insetsLayoutMarginsFromSafeArea = false
        contentContainer.layoutMargins = UIEdgeInsets(horizontalInset: 16, verticalInset: 10)
        backgroundView.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let label = UILabel(value: "Got questions? Write to us here", style: .brand(.body(color: .primary(state: .negative))))
        contentContainer.addArrangedSubview(label)

        return (backgroundView, bag)
    }
}
