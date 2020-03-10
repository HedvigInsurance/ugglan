//
//  End.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-07.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import DeviceKit
import Flow
import Foundation
import UIKit
import ComponentKit

struct End {
    let dismissSignal: Signal<Void>
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
        bag += stackView.addArranged(happyAvatar)

        let sayHello = SayHello()
        bag += stackView.addArranged(sayHello)

        bag += stackView.didLayoutSignal.take(first: 1).onValue { _ in
            let marketingScreenButton = SharedElement.retreive(
                for: SharedElementIdentities.newMemberButtonMarketingScreen
            )
            let endScreenButton = SharedElement.retreive(
                for: SharedElementIdentities.newMemberButtonEndScreen
            )

            if let marketingScreenButton = marketingScreenButton, let endScreenButton = endScreenButton {
                bag += self.dismissSignal.map { _ -> CGAffineTransform in
                    CGAffineTransform.identity
                }.bindTo(animate: AnimationStyle.easeOut(duration: 0.3), marketingScreenButton, \.transform)

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

        bag += stackView.didMoveToWindowSignal.delay(by: 0.1).animated(
            style: AnimationStyle.easeOut(duration: 0.5)
        ) {
            stackView.alpha = 1
        }

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }

        bag += view.didMoveToWindowSignal.take(first: 1).onValue({ _ in
            view.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
        })

        return (view, Future { completion in
            let newMemberButton = NewMemberButton(style: .endScreen) {
                completion(.success(.onboard))
            }
            bag += stackView.addArranged(newMemberButton)

            let existingMemberButtonContainerView = UIView()

            let existingMemberButton = ExistingMemberButton {
                completion(.success(.login))
            }
            bag += existingMemberButtonContainerView.add(existingMemberButton) { buttonView in
                buttonView.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                }
            }

            view.addSubview(existingMemberButtonContainerView)

            bag += existingMemberButtonContainerView.didMoveToWindowSignal.take(first: 1).onValue({ _ in
                existingMemberButtonContainerView.snp.makeConstraints { make in
                    if Device.hasRoundedCorners {
                        make.bottom.equalTo(existingMemberButtonContainerView.safeAreaLayoutGuide.snp.bottom)
                    } else {
                        make.bottom.equalTo(-15)
                    }

                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview()
                    make.height.equalTo(30)
                }
            })

            bag += events.removeAfter.set { _ -> TimeInterval in
                2
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
