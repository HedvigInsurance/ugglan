//
//  SlideToClaim.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Ease
import Flow
import Form
import Foundation
import hCore
import UIKit

struct SlideToClaim: SignalProvider {
    var providedSignal: CoreSignal<Finite, Void> {
        return providedSignalCallbacker.signal().take(first: 1)
    }

    private let providedSignalCallbacker = Callbacker<Void>()
}

extension SlideToClaim: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        let bag = DisposeBag()

        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints { make in
                make.height.equalTo(50)
                make.center.equalToSuperview()
            }
        }

        let track = UIView()
        track.backgroundColor = .primaryBackground

        view.addSubview(track)

        track.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }

        let trackLabel = UILabel(
            value: L10n.claimsPledgeSlideLabel,
            style: TextStyle.body.centerAligned
        )
        view.addSubview(trackLabel)

        trackLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }

        let handle = UIView()
        handle.backgroundColor = .primaryButtonBackgroundColor

        let continueIcon = Icon(icon: Asset.continue, iconWidth: 20)
        handle.addSubview(continueIcon)

        continueIcon.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.center.equalToSuperview()
        }

        view.addSubview(handle)

        handle.snp.makeConstraints { make in
            make.width.equalTo(view.snp.height)
            make.height.equalToSuperview()
            make.left.equalTo(0)
            make.center.equalToSuperview()
        }

        let pan = UIPanGestureRecognizer()
        bag += view.install(pan)

        let ease: Ease<CGFloat> = Ease(handle.center.x, minimumStep: 0.001)

        bag += ease.addSpring(tension: 200, damping: 20, mass: 1) { position in
            handle.center.x = position
        }

        bag += providedSignal.feedback(type: .success)

        var handleCenterX: CGFloat {
            return handle.frame.width / 2
        }

        bag += pan.signal(forState: .changed).onValue {
            let location = pan.translation(in: view)

            let maxLocationX = track.frame.size.width - handle.frame.size.width
            let cappedLocationX = location.x >= maxLocationX ? maxLocationX : location.x

            if location.x >= maxLocationX {
                self.providedSignalCallbacker.callAll()
            }

            let tracklabelOriginX = (view.frame.width - trackLabel.intrinsicContentSize.width) / 2
            trackLabel.alpha = 1 - (cappedLocationX / tracklabelOriginX)

            ease.value = max(handleCenterX + cappedLocationX, handleCenterX)
            handle.center.x = ease.value
            ease.targetValue = ease.value
        }

        bag += pan.signal(forState: .ended).onValue {
            ease.velocity = pan.velocity(in: view).x
            ease.targetValue = handleCenterX
        }

        bag += pan.signal(forState: .ended).animated(style: .easeOut(duration: 0.25), animations: { _ in
            trackLabel.alpha = 1
        })

        bag += view.didLayoutSignal.onValue {
            track.layer.cornerRadius = view.frame.height / 2
            handle.layer.cornerRadius = view.frame.height / 2
        }

        return (view, bag)
    }
}
