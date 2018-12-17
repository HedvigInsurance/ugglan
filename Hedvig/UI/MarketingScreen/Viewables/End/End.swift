//
//  End.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-07.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

struct End {
    let dismissGesture: Signal<UIPanGestureRecognizer>
}

class CenterAllStackView: UIStackView {
    let horizontalStackView = UIStackView()
    let internalStackView = UIStackView()

    override var alignment: UIStackView.Alignment {
        get {
            return internalStackView.alignment
        }
        set(newValue) {
            internalStackView.alignment = newValue
        }
    }

    override var axis: NSLayoutConstraint.Axis {
        get {
            return internalStackView.axis
        }
        set(newValue) {
            internalStackView.axis = newValue
        }
    }

    override var spacing: CGFloat {
        get {
            return internalStackView.spacing
        }
        set(newValue) {
            internalStackView.spacing = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        super.alignment = .center
        super.axis = .vertical

        horizontalStackView.alignment = .center
        horizontalStackView.axis = .horizontal

        addArrangedSubview(horizontalStackView)

        horizontalStackView.addArrangedSubview(internalStackView)
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func addArrangedSubview(_ view: UIView) {
        if view == horizontalStackView {
            super.addArrangedSubview(view)
            return
        }

        internalStackView.addArrangedSubview(view)
    }
}

extension End: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = CenterAllStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 20
        view.alpha = 0

        let bag = DisposeBag()

        let happyAvatar = HappyAvatar()
        bag += view.addArangedSubview(happyAvatar)

        let sayHello = SayHello()
        bag += view.addArangedSubview(sayHello)

        let newMemberButton = NewMemberButton(style: .endScreen) {}
        bag += view.addArangedSubview(newMemberButton)

        let existingMemberButtonContainerView = UIView()
        existingMemberButtonContainerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, safeArea in
            make.bottom.equalTo(safeArea.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }

        let existingMemberButton = ExistingMemberButton {}
        bag += existingMemberButtonContainerView.add(existingMemberButton)

        view.addSubview(existingMemberButtonContainerView)

        bag += view.didLayoutSignal.take(first: 1).onValue { _ in
            let marketingScreenButton = SharedElement.retreive(
                for: SharedElementIdentities.newMemberButtonMarketingScreen
            )
            let endScreenButton = SharedElement.retreive(
                for: SharedElementIdentities.newMemberButtonEndScreen
            )

            if let marketingScreenButton = marketingScreenButton, let endScreenButton = endScreenButton {
                bag += self.dismissGesture.map({ _ -> CGAffineTransform in
                    CGAffineTransform.identity
                }).bindTo(animate: AnimationStyle.easeOut(duration: 0.3), marketingScreenButton, \.transform)

                let transformFrame = endScreenButton.frameRelativeTo(view: marketingScreenButton)

                endScreenButton.transform = CGAffineTransform(translationX: 0, y: transformFrame.origin.y)
                endScreenButton.alpha = 0

                bag += Signal(after: 0.15).animated(
                    style: AnimationStyle.easeOut(duration: 0.5)
                ) {
                    endScreenButton.alpha = 1
                }

                bag += Signal(after: 0.1).animated(
                    style: SpringAnimationStyle.heavyBounce()
                ) {
                    endScreenButton.transform = CGAffineTransform.identity
                    marketingScreenButton.transform = CGAffineTransform(translationX: 0, y: -transformFrame.origin.y)
                }
            }
        }

        _ = view.didMoveToWindowSignal.delay(by: 0.1).animated(
            style: AnimationStyle.easeOut(duration: 0.5)
        ) {
            view.alpha = 1
        }

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue({ make, _ in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        })

        return (view, bag)
    }
}
