//
//  TypingIndicator.swift
//  project
//
//  Created by Axel Backlund on 2019-08-09.
//

import Flow
import Foundation
import Presentation
import Form
import UIKit

struct TypingIndicator: Hashable {
    let id = UUID()
}

extension TypingIndicator: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (TypingIndicator) -> Disposable) {
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .leading
        containerView.distribution = .equalCentering

        let spacingContainer = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .leading
        spacingContainer.insetsLayoutMarginsFromSafeArea = false
        spacingContainer.isLayoutMarginsRelativeArrangement = true
        spacingContainer.edgeInsets = UIEdgeInsets(top: 2, left: 20, bottom: 0, right: 20)
        
        containerView.addArrangedSubview(spacingContainer)
        
        return (containerView, { typingIndicator in
            return spacingContainer.addArranged(typingIndicator)
        })
    }
}

extension TypingIndicator: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let bubble = UIView()
        bubble.backgroundColor = .secondaryBackground
        
        let typingView = UIStackView()
        typingView.spacing = 5
        typingView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 15)
        typingView.isLayoutMarginsRelativeArrangement = true

        bubble.addSubview(typingView)
        typingView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        func getDot(color: HedvigColor) -> UIView {
            let dot = UIView()
            dot.snp.makeConstraints { make in
                make.width.height.equalTo(5)
            }
            dot.layer.cornerRadius = 2.5
            dot.backgroundColor = UIColor.from(apollo: color)
            return dot
        }

        let firstDot = getDot(color: .darkGray)
        let secondDot = getDot(color: .darkGray)
        let thirdDot = getDot(color: .darkGray)

        typingView.addArrangedSubview(firstDot)
        typingView.addArrangedSubview(secondDot)
        typingView.addArrangedSubview(thirdDot)

        bag += bubble.didLayoutSignal.onValue({ _ in
            bubble.layer.cornerRadius = 20
        })

        bag += Signal(every: 2, delay: 0).animated(style: AnimationStyle.easeOut(duration: 0.2), animations: { _ in
            firstDot.transform = CGAffineTransform(translationX: 0, y: -10)
        }).animated(style: SpringAnimationStyle.ludicrousBounce(), animations: { _ in
            firstDot.transform = CGAffineTransform.identity
        })

        bag += Signal(every: 2, delay: 0.1).animated(style: AnimationStyle.easeOut(duration: 0.2), animations: { _ in
            secondDot.transform = CGAffineTransform(translationX: 0, y: -6)
        }).animated(style: SpringAnimationStyle.ludicrousBounce(), animations: { _ in
            secondDot.transform = CGAffineTransform.identity
        })

        bag += Signal(every: 2, delay: 0.2).animated(style: AnimationStyle.easeOut(duration: 0.2), animations: { _ in
            thirdDot.transform = CGAffineTransform(translationX: 0, y: -4)
        }).animated(style: SpringAnimationStyle.ludicrousBounce(), animations: { _ in
            thirdDot.transform = CGAffineTransform.identity
        })

        return (bubble, bag)
    }
}
