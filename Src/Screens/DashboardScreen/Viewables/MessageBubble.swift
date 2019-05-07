//
//  MessageBubble.swift
//  project
//
//  Created by Sam Pettersson on 2019-05-07.
//

import Foundation
import UIKit
import Flow
import Form

struct MessageBubble {
    let textSignal = ReadWriteSignal<String>("")
}

extension MessageBubble: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .leading
        
        let stylingView = UIView()
        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
        
        let label = MultilineLabel(value: "", style: .bodyOffBlack, usePreferredMaxLayoutWidth: false)
        bag += containerView.addArranged(label) { labelView in
            bag += textSignal.map { StyledText(text: $0, style: .bodyOffBlack) }.animated(style: SpringAnimationStyle.lightBounce(), animations: { styledText in
                labelView.alpha = 0
            }).animated(style: SpringAnimationStyle.lightBounce(), animations: { styledText in
                label.styledTextSignal.value = styledText
                containerView.layoutIfNeeded()
                containerView.layoutSuperviewsIfNeeded()
            }).animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                labelView .alpha = 1
            })
        }
        
        stylingView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
            make.width.lessThanOrEqualTo(200)
        }
        
        stylingView.backgroundColor = .offLightGray
        stylingView.layer.cornerRadius = 30
        
        bag += stylingView.didLayoutSignal.onValue { _ in
            stylingView.layer.cornerRadius = min(stylingView.frame.height / 2, 20)
        }
        
        containerStackView.addArrangedSubview(stylingView)
        
        return (containerStackView, bag)
    }
}
