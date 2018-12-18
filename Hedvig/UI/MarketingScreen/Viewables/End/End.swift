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

extension End: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Future<MarketingResult>) {
        let view = UIView()

        let stackView = CenterAllStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alpha = 0

        view.addSubview(stackView)

        let bag = DisposeBag()

        let happyAvatar = HappyAvatar()
        bag += stackView.addArangedSubview(happyAvatar)

        let sayHello = SayHello()
        bag += stackView.addArangedSubview(sayHello)

        bag += stackView.didLayoutSignal.take(first: 1).onValue { _ in
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

        _ = stackView.didMoveToWindowSignal.delay(by: 0.1).animated(
            style: AnimationStyle.easeOut(duration: 0.5)
        ) {
            stackView.alpha = 1
        }

        bag += stackView.makeConstraints(wasAdded: events.wasAdded).onValue({ make, _ in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        })

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue({ make, _ in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        })

        return (view, Future { completion in
            let newMemberButton = NewMemberButton(style: .endScreen) {
                completion(.success(.onboard))
            }
            bag += stackView.addArangedSubview(newMemberButton)

            let existingMemberButtonContainerView = UIView()

            let existingMemberButton = ExistingMemberButton {
                completion(.success(.login))
            }
            bag += existingMemberButtonContainerView.add(existingMemberButton)

            view.addSubview(existingMemberButtonContainerView)

            bag += existingMemberButtonContainerView.makeConstraints(
                wasAdded: events.wasAdded
            ).onValue { make, safeArea in
                make.bottom.equalTo(safeArea)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(30)
            }

            bag += events.removeAfter.set({ _ -> TimeInterval in
                2
            })

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
