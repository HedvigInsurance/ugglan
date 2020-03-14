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
import ComponentKit

struct MessageBubble {
    let textSignal: ReadWriteSignal<String>
    let delay: TimeInterval

    init(text: String, delay: TimeInterval) {
        self.delay = delay
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
        bag += stylingView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.05,
                offset: CGSize(width: 0, height: 6),
                radius: 8,
                color: UIColor.primaryShadowColor,
                path: nil
            )
        }
        stylingView.alpha = 0

        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)

        let label = MultilineLabel(value: "", style: .bodyOffBlack, usePreferredMaxLayoutWidth: false)
        bag += containerView.addArranged(label) { labelView in
            bag += labelView.copySignal.onValue { _ in
                UIPasteboard.general.string = labelView.text
            }

            labelView.alpha = 0

            bag += textSignal
                .atOnce()
                .map { StyledText(text: $0, style: .bodyOffBlack) }
                .delay(by: delay)
                .animated(style: SpringAnimationStyle.lightBounce()) { styledText in
                    label.styledTextSignal.value = styledText
                    containerStackView.isHidden = false
                    stylingView.alpha = 1
                }.animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                    labelView.alpha = 1
                }
        }

        stylingView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
            make.width.lessThanOrEqualTo(300)
        }

        stylingView.backgroundColor = .secondaryBackground
        stylingView.layer.cornerRadius = 30

        bag += merge(stylingView.didMoveToWindowSignal, stylingView.didLayoutSignal).onValue { _ in
            stylingView.layer.cornerRadius = min(stylingView.frame.height / 2, 20)
        }

        containerStackView.addArrangedSubview(stylingView)

        return (containerStackView, bag)
    }
}
