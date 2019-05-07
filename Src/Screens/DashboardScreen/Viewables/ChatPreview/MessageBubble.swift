//
//  MessageBubble.swift
//  project
//
//  Created by Sam Pettersson on 2019-05-07.
//

import Flow
import Form
import Foundation
import UIKit

struct MessageBubble {
    let textSignal: ReadWriteSignal<String>

    init(text: String) {
        textSignal = ReadWriteSignal(text)
    }
}

extension MessageBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .leading
        containerStackView.isHidden = true

        let stylingView = UIView()
        stylingView.layer.shadowOpacity = 0.05
        stylingView.layer.shadowOffset = CGSize(width: 0, height: 6)
        stylingView.layer.shadowRadius = 8
        stylingView.layer.shadowColor = UIColor.darkGray.cgColor
        stylingView.alpha = 0

        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)

        let label = MultilineLabel(value: "", style: .bodyOffBlack, usePreferredMaxLayoutWidth: false)
        bag += containerView.addArranged(label) { labelView in
            bag += labelView.copySignal.onValue { _ in
                UIPasteboard.general.string = labelView.text
            }

            bag += textSignal.atOnce().map { StyledText(text: $0, style: .bodyOffBlack) }.animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                labelView.alpha = 0
            }).animated(style: SpringAnimationStyle.lightBounce(), animations: { styledText in
                label.styledTextSignal.value = styledText
                containerStackView.isHidden = false
                containerView.layoutIfNeeded()
                stylingView.layoutIfNeeded()
                containerStackView.layoutIfNeeded()
                stylingView.alpha = 1
            }).animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                labelView.alpha = 1
            })
        }

        stylingView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
            make.width.lessThanOrEqualTo(300)
        }

        stylingView.backgroundColor = .white
        stylingView.layer.cornerRadius = 30

        bag += merge(stylingView.didMoveToWindowSignal, stylingView.didLayoutSignal).onValue { _ in
            stylingView.layer.cornerRadius = min(stylingView.frame.height / 2, 20)
        }

        containerStackView.addArrangedSubview(stylingView)

        return (containerStackView, bag)
    }
}
