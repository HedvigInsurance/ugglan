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

extension UIViewController {
    var preferredContentSizeSignal: ReadSignal<CGSize> {
        let signal = ReadWriteSignal(preferredContentSize)
        
        var observer: NSKeyValueObservation? = self.observe(\.preferredContentSize) { [weak self] _, _ in
            signal.value = self?.preferredContentSize ?? signal.value
        }
        
        let bag = DisposeBag()
        
        bag += deallocSignal.onValue { _ in
            observer?.invalidate()
            observer = nil
            bag.dispose()
        }
        
        return signal.readOnly()
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

        bag += view.didMoveToWindowSignal.take(first: 1).map { true }.onValue(animateDimmingViewVisibility)

        let overlay = UIView()
        overlay.clipsToBounds = false
        overlay.alpha = 0

        view.addSubview(overlay)
        
        overlay.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(0)
            make.center.equalToSuperview()
        }
        
        let overshoot = UIView()
        overshoot.backgroundColor = .white
        
        overlay.addSubview(overshoot)
        
        bag += view.didLayoutSignal.onValue { _ in
            overshoot.snp.remakeConstraints { make in
                make.height.equalTo(view.snp.height)
                make.top.equalTo(overlay.snp.bottom).inset(20)
                make.width.equalToSuperview()
            }
        }

        let overlayHeightSignal = ReadWriteSignal<CGFloat>(0)
        var dragLimit: CGFloat {
            var safeAreaTop: CGFloat {
                if #available(iOS 11.0, *) {
                    return view.safeAreaInsets.top
                } else {
                    return 0
                }
            }
            let extraPadding = safeAreaTop + 70
            return overlayHeightSignal.value - (view.frame.height - extraPadding)
        }
        
        let ease: Ease<CGFloat> = Ease(UIScreen.main.bounds.height, minimumStep: 0.001)
        
        func overlayCenter() -> CGFloat {
            var bottomPadding: CGFloat {
                if #available(iOS 11.0, *) {
                    return view.safeAreaInsets.bottom
                }
                
                return 0
            }
            
            return UIScreen.main.bounds.height - (overlayHeightSignal.value / 2)
        }
        
        bag += overlayHeightSignal.distinct().skip(first: 1).animated(style: SpringAnimationStyle.lightBounce()) { overlayHeight in
            overlay.snp.updateConstraints { make in
                make.height.equalTo(overlayHeight)
            }
            
            overlay.layoutIfNeeded()
            view.layoutIfNeeded()
            overshoot.layoutIfNeeded()
            
            overlay.center.y = overlayCenter()
            ease.value = overlay.center.y
            ease.targetValue = overlay.center.y
        }
        
        let (childScreen, childResult) = presentable.materialize()
        childScreen.setLargeTitleDisplayMode(presentationOptions)
        
        let embeddedChildScreen = childScreen.embededInNavigationController(presentationOptions)
        
        // initial entry animation
        bag += overlayHeightSignal.filter(predicate: { $0 != 0 }).wait(until: view.hasWindowSignal).take(first: 1).onValue { overlayHeight in
            let originalCenterY = view.frame.height + overlayHeight
            overlay.center.y = originalCenterY
            ease.value = originalCenterY
            
            overlay.snp.updateConstraints { make in
                make.height.equalTo(overlayHeight)
            }
            
            overlay.layoutIfNeeded()
            overshoot.layoutIfNeeded()
            view.layoutIfNeeded()
            
            bag += Signal(after: 0.1).onValue({ _ in
                ease.velocity = 0.1
                ease.targetValue = overlayCenter()
                overlay.alpha = 1
            })
        }
        
        let panGestureRecognizer = UIPanGestureRecognizer()

        bag += panGestureRecognizer.signal(forState: .changed).onValue {
            let location = panGestureRecognizer.translation(in: view)

            if (location.y < dragLimit) {
                ease.value = max(overlayCenter() + (dragLimit * (1 + log10(location.y / dragLimit))), overlayCenter() + dragLimit - 60)
                ease.targetValue = ease.value
                return
            }
           
            ease.value = overlayCenter() + location.y
            ease.targetValue = ease.value
        }

        bag += ease.addSpring(tension: 200, damping: 20, mass: 1) { position in
            overlay.center.y = position
        }

        bag += panGestureRecognizer.signal(forState: .ended).onValue { _ in
            ease.velocity = panGestureRecognizer.velocity(in: view).y
            ease.targetValue = overlayCenter()
        }

        bag += overlay.install(panGestureRecognizer)

        let overlayContainer = UIView()
        overlayContainer.backgroundColor = .white
        overlayContainer.layer.cornerRadius = 19
        overlayContainer.clipsToBounds = true

        overlay.addSubview(overlayContainer)

        overlayContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }

        let handleView = UIView()
        handleView.backgroundColor = .transparent
        handleView.translatesAutoresizingMaskIntoConstraints = true

        overlay.addSubview(handleView)

        handleView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.top.equalTo(-22)
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
        
        overlayContainer.addSubview(embeddedChildScreen.view)
        
        embeddedChildScreen.view.snp.makeConstraints { make in
            make.width.equalTo(overlay.snp.width)
            make.height.equalTo(overlay.snp.height)
            make.center.equalTo(overlay.snp.center)
        }
        
        if let navigationController = embeddedChildScreen as? UINavigationController {
            bag += navigationController.viewControllersSignal.atOnce().onValueDisposePrevious { viewControllers -> Disposable? in
                let innerBag = bag.innerBag()
                innerBag += viewControllers.last?.preferredContentSizeSignal.atOnce().map { size in size.height }.bindTo(overlayHeightSignal)
                return innerBag
            }
        } else {
            overlayHeightSignal.value = childScreen.preferredContentSize.height
        }
        
        return (viewController, Future { completion in
            func hideOverlay() {
                bag += Signal(after: 0.5).onValue {
                    completion(.success)
                    overlay.isHidden = true
                }
                animateDimmingViewVisibility(false)
                ease.targetValue = view.frame.height + (overlay.frame.height / 2)
            }

            bag += panGestureRecognizer.signal(forState: .ended).onValue { _ in
                let velocity = panGestureRecognizer.velocity(in: view)
                let translation = panGestureRecognizer.translation(in: view)
                
                if translation.y > (overlayHeightSignal.value * 0.4) || velocity.y > 1300 {
                    hideOverlay()
                }
            }

            bag += dimmingViewTap.signal(forState: .recognized).onValue {
                hideOverlay()
            }

            bag += childResult.onValue { _ in
                hideOverlay()
            }

            return bag
        })
    }
}
