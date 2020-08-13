//
//  UIViewController+Toast.swift
//  hCoreUI
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import UIKit

struct Toast: Viewable {
    let value: String

    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let containerView = UIView()
        
        let effectView = UIVisualEffectView()
        effectView.layer.cornerRadius = 8
        effectView.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            effectView.effect = UIBlurEffect(style: .systemChromeMaterial)
        } else {
            effectView.effect = UIBlurEffect(style: .prominent)
        }
        containerView.addSubview(effectView)
        
        effectView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        
        let bag = DisposeBag()

        bag += effectView.applyShadow { _ -> UIView.ShadowProperties in
            .init(
                opacity: 0.1,
                offset: CGSize(width: 0, height: 4),
                radius: 16,
                color: UIColor.black,
                path: nil
            )
        }

        let contentView = UIStackView()
        contentView.layoutMargins = UIEdgeInsets(inset: 15)
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.insetsLayoutMarginsFromSafeArea = false
        effectView.contentView.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        bag += contentView.addArranged(MultilineLabel(value: value, style: TextStyle.brand(.headline(color: .primary(state: .dynamicReversed))).centerAligned))

        return (containerView, bag)
    }
}

var toastTag: Int = {
    String("toast").map { char in
        Int(char.asciiValue ?? 0)
    }.compactMap { $0 }.reduce(0) { result, value in
        result + value
    }
}()

public extension UIViewController {
    func displayToast(title: String) -> Disposable {
        if let navigationController = navigationController {
            return navigationController.displayToast(title: title)
        }

        if view.subviews.contains(where: { view -> Bool in
            view.tag == toastTag
        }) {
            return NilDisposer()
        }

        let bag = DisposeBag()

        let (toastView, toastBag) = Toast(value: title).materialize(events: ViewableEvents(wasAddedCallbacker: .init()))
        bag += toastBag
        toastView.transform = CGAffineTransform(translationX: 0, y: -200)
        toastView.tag = toastTag

        view.embedView(
            toastView,
            withinLayoutArea: .safeArea,
            edgeInsets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0),
            pinToEdges: .top,
            layoutPriority: .required,
            disembedBag: nil
        )

        toastView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(15)
        }

        bag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            toastView.transform = .identity
        }

        let gestureRecognizer = UIPanGestureRecognizer()
        bag += toastView.install(gestureRecognizer)

        bag += gestureRecognizer.signal(forState: .changed).onValue {
            toastView.transform = CGAffineTransform(translationX: 0, y: min(gestureRecognizer.translation(in: toastView).y, 0))
        }

        let timeoutSignal = Signal(after: 2).map { true }.readable(initial: false)

        bag += gestureRecognizer.signal(forState: .ended).withLatestFrom(timeoutSignal.atOnce().plain()).animated(style: SpringAnimationStyle.lightBounce()) { _, hasTimedOut in
            if hasTimedOut {
                return
            }

            if gestureRecognizer.translation(in: toastView).y < -20 {
                toastView.transform = CGAffineTransform(translationX: 0, y: -200)
            } else {
                toastView.transform = CGAffineTransform.identity
            }
        }

        bag += timeoutSignal
            .atOnce()
            .filter(predicate: { $0 })
            .wait(until: gestureRecognizer.signal(for: \.state).atOnce().map { state in state == .ended || state == .possible })
            .animated(style: SpringAnimationStyle.lightBounce()) { _ in
                toastView.transform = CGAffineTransform(translationX: 0, y: -200)
            }.onValue { _ in
                toastView.removeFromSuperview()
                bag.dispose()
            }

        return bag
    }
}
