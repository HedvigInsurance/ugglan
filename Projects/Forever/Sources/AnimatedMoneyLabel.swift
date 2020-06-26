//
//  AnimatedMoneyLabel.swift
//  Forever
//
//  Created by sam on 17.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import UIKit
import Form

struct AnimatedSavingsLabel {
    let from: ReadSignal<MonetaryAmount?>
    let to: ReadSignal<MonetaryAmount?>
    let textAlignment: NSTextAlignment
}

extension AnimatedSavingsLabel: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let maskContainer = UIView()
        
        let gradientMaskLayer = CAGradientLayer()
        
        bag += maskContainer.didLayoutSignal.onValue {
            gradientMaskLayer.frame = maskContainer.bounds
        }
        
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0, 0.1, 0.9, 1]
        
        maskContainer.layer.mask = gradientMaskLayer
        
        let container = UIStackView()
        maskContainer.addSubview(container)
        container.axis = .vertical
        
        container.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        let fromLabel = UILabel(value: " ", style: TextStyle.brand(.title2(color: .primary)).aligned(to: textAlignment))
        fromLabel.transform = CGAffineTransform(translationX: 0, y: -100)
        container.addArrangedSubview(fromLabel)
        
        bag += from.atOnce().onValue { amount in
            fromLabel.value = amount?.formattedAmount ?? " "
        }
        
        let toLabel = UILabel(value: "", style: TextStyle.brand(.title2(color: .primary)).aligned(to: textAlignment))
        toLabel.isHidden = true
        container.addArrangedSubview(toLabel)
        
        bag += to.atOnce().onValue { amount in
            toLabel.value = amount?.formattedAmount ?? ""
        }
        
        bag += combineLatest(from, to).toVoid().animated(style: SpringAnimationStyle.lightBounce()) { _ in
            fromLabel.transform = .identity
            toLabel.transform = CGAffineTransform(translationX: 0, y: -100)
        }.delay(by: 1.5).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            fromLabel.isHidden = true
            fromLabel.alpha = 0
            fromLabel.transform = CGAffineTransform(translationX: 0, y: 100)
            toLabel.isHidden = false
            toLabel.alpha = 1
            toLabel.transform = .identity
        }
        
        return (maskContainer, bag)
    }
}
