//
//  Passage.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Flow
import Form
import Foundation
import hCore
import UIKit

struct Passage {
    let state: EmbarkState
}

extension Passage: Viewable {
    func goBackPanGesture(_ view: UIView, actionView: UIView) -> Disposable {
        let bag = DisposeBag()

        let panGestureRecognizer = UIPanGestureRecognizer()
        let hasSentFeedback = ReadWriteSignal(false)

        let releaseToGoBackLabel = UILabel(
            value: "Release to go back",
            style: TextStyle.brand(.footnote(color: .tertiary)).centerAligned
        )
        releaseToGoBackLabel.alpha = 0

        view.addSubview(releaseToGoBackLabel)

        releaseToGoBackLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-20)
            make.left.right.equalToSuperview()
        }

        bag += panGestureRecognizer.signal(forState: .began).onValue { _ in
            if panGestureRecognizer.translation(in: view).y < 0 {
                panGestureRecognizer.state = .ended
            }
        }

        bag += panGestureRecognizer
            .signal(forState: .changed)
            .filter(predicate: { _ in self.state.canGoBackSignal.value })
            .onValue { _ in
                let translationY = max(
                    panGestureRecognizer.translation(in: view).y,
                    panGestureRecognizer.translation(in: view).y / 25
                )
                view.transform = CGAffineTransform(translationX: 0, y: min(translationY, 50 + (translationY / 25)))

                releaseToGoBackLabel.alpha = (translationY - 35) / 50
                releaseToGoBackLabel.transform = CGAffineTransform(translationX: 0, y: -min(0, 50 + (translationY / 100)))
                actionView.transform = CGAffineTransform(translationX: 0, y: -min(translationY, 50 + (translationY / 100)))

                if translationY > 50, hasSentFeedback.value == false {
                    hasSentFeedback.value = true
                    bag += Signal(after: 0).feedback(type: .selection)
                } else if translationY < 50 {
                    hasSentFeedback.value = false
                }

                if translationY > 200 {
                    panGestureRecognizer.state = .ended
                }
            }

        bag += panGestureRecognizer
            .signal(forState: .ended)
            .filter(predicate: { _ in self.state.canGoBackSignal.value })
            .debounce(0.25)
            .animated(style: SpringAnimationStyle.heavyBounce()) { _ in
                hasSentFeedback.value = false
                if panGestureRecognizer.translation(in: view).y > 40 {
                    self.state.goBack()
                    bag += Signal(after: 0).feedback(type: .impactLight)
                }

                releaseToGoBackLabel.alpha = 0
                view.transform = CGAffineTransform(translationX: 0, y: 0)
            }

        view.addGestureRecognizer(panGestureRecognizer)

        return bag
    }

    func materialize(events _: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        let bag = DisposeBag()

        let embarkMessages = EmbarkMessages(
            state: state
        )
        bag += view.addArranged(embarkMessages)

        let action = Action(
            state: state
        )

        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: keyboardInfo.height, right: 20)
                view.layoutIfNeeded()
        })

        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillHideNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { _ in
                view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                view.layoutIfNeeded()
        })

        return (view, Signal { callback in
            bag += view.addArranged(action) { actionView in
                bag += self.goBackPanGesture(view, actionView: actionView)
            }.onValue(callback)
            return bag
        })
    }
}
