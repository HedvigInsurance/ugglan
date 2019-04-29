//
//  DraggableOverlay.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-13.
//

import Ease
import Flow
import Foundation
import Presentation
import UIKit

struct DraggableOverlay<P: Presentable, PMatter: UIViewController, FutureResult: Any> where P.Matter == PMatter, P.Result == Future<FutureResult> {
    let presentable: P
    let presentationOptions: PresentationOptions
    let backgroundColor: UIColor
    let heightPercentage: CGFloat

    init(
        presentable: P,
        presentationOptions: PresentationOptions = .defaults,
        backgroundColor: UIColor = .white,
        heightPercentage: CGFloat = 0.5
    ) {
        self.presentable = presentable
        self.presentationOptions = presentationOptions
        self.backgroundColor = backgroundColor
        self.heightPercentage = heightPercentage
    }
}

extension PresentationStyle {
    /// makes PresentationOptions passed to style be [.unanimated] and only that
    static func unanimated(style: PresentationStyle) -> PresentationStyle {
        return PresentationStyle(name: "unanimated-(\(style.name))") { viewController, from, _ in
            style.present(viewController, from: from, options: [.unanimated])
        }
    }
}

extension DraggableOverlay: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.preferredPresentationStyle = PresentationStyle.unanimated(style: .modally(
            presentationStyle: .custom,
            transitionStyle: nil,
            capturesStatusBarAppearance: false
        ))

        let bag = DisposeBag()

        let view = UIView()
        viewController.view = view

        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black
        dimmingView.alpha = 0

        let dimmingViewTap = UITapGestureRecognizer()

        bag += dimmingView.install(dimmingViewTap)

        view.addSubview(dimmingView)

        dimmingView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }

        let animateDimmingViewVisibility = { (visible: Bool) -> Void in
            bag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.25)) {
                dimmingView.alpha = visible ? 0.2 : 0
            }
        }

        bag += dimmingView.didLayoutSignal.take(first: 1).map { true }.onValue(animateDimmingViewVisibility)

        let overlay = UIView()
        overlay.clipsToBounds = true

        view.addSubview(overlay)

        let overlayHeight: CGFloat = round(heightPercentage * UIScreen.main.bounds.height)
        let overshootHeight: CGFloat = 800
        let dragLimit = overlayHeight - UIScreen.main.bounds.height + 60

        overlay.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(overshootHeight + overlayHeight)
            make.bottom.equalTo(overshootHeight + overlayHeight)
        }

        func overlayCenter() -> CGFloat {
            return view.frame.height / 2 + overshootHeight - (overlayHeight / 2)
        }

        let panGestureRecognizer = UIPanGestureRecognizer()
        let ease: Ease<CGFloat> = Ease(overlay.center.y, minimumStep: 0.001)

        bag += overlay.didLayoutSignal.take(first: 1).onValue {
            ease.value = overlay.center.y
            ease.velocity = 0.1
            ease.targetValue = overlayCenter()
        }

        bag += panGestureRecognizer.signal(forState: .changed).onValue {
            let location = panGestureRecognizer.translation(in: view)

            if location.y < dragLimit {
                ease.velocity = panGestureRecognizer.velocity(in: view).y * 0.20
                ease.targetValue = overlayCenter() + dragLimit + location.y * 0.015
            } else {
                ease.velocity = panGestureRecognizer.velocity(in: view).y * 1.35
                ease.targetValue = overlayCenter() + location.y
            }
        }

        bag += ease.addSpring(tension: 200, damping: 20, mass: 1) { position in
            overlay.center.y = position
        }

        bag += panGestureRecognizer.signal(forState: .ended).onValue { _ in
            ease.velocity = panGestureRecognizer.velocity(in: view).y
            ease.targetValue = overlayCenter()
        }

        bag += overlay.install(panGestureRecognizer)
        
        let (childScreen, childResult) = presentable.materialize()
        childScreen.setLargeTitleDisplayMode(presentationOptions)

        let embeddedChildScreen = childScreen.embededInNavigationController(presentationOptions)

        let overlayContainer = UIView()
        overlayContainer.backgroundColor = .white
        overlayContainer.layer.cornerRadius = 19
        overlayContainer.clipsToBounds = true

        overlay.addSubview(overlayContainer)

        overlayContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalTo(22)
        }

        let handleView = UIView()
        handleView.backgroundColor = .transparent
        handleView.translatesAutoresizingMaskIntoConstraints = true

        overlay.addSubview(handleView)

        handleView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.top.equalTo(0)
        }

        let handle = UIView()
        handle.backgroundColor = .white
        handle.alpha = 0.8
        handle.layer.cornerRadius = 3

        handleView.addSubview(handle)

        handle.snp.makeConstraints { make in
            make.width.equalTo(52)
            make.height.equalTo(6)
            make.centerX.centerY.equalToSuperview()
        }

        viewController.addChild(embeddedChildScreen)

        embeddedChildScreen.view.translatesAutoresizingMaskIntoConstraints = false
        overlayContainer.addSubview(embeddedChildScreen.view)

        embeddedChildScreen.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(overlayHeight)
        }

        return (viewController, Future { completion in
            func hideOverlay() {
                bag += Signal(after: 0.5).onValue {
                    completion(.success)
                }
                animateDimmingViewVisibility(false)
                ease.targetValue = view.frame.height * 2
            }

            bag += panGestureRecognizer.signal(forState: .ended).onValue { _ in
                let velocity = panGestureRecognizer.velocity(in: view)
                let translation = panGestureRecognizer.translation(in: view)

                if translation.y > (overlayHeight * 0.4) || velocity.y > 1300 {
                    hideOverlay()
                }
            }

            bag += dimmingViewTap.signal(forState: .recognized).onValue {
                hideOverlay()
            }
            
            bag += childResult.onValue({ _ in
                hideOverlay()
            })
            
            return bag
        })
    }
}
