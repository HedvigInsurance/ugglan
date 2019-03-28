//
//  DraggableOverlay.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-13.
//

import Foundation
import Presentation
import UIKit
import Flow

struct DraggableOverlay<P: Presentable, PMatter: UIViewController> where P.Result == Disposable, P.Matter == PMatter {
    let presentable: P
    let presentationOptions: PresentationOptions
    let backgroundColor: UIColor
    
    init(
        presentable: P,
        presentationOptions: PresentationOptions = .defaults,
        backgroundColor: UIColor = .white
    ) {
        self.presentable = presentable
        self.presentationOptions = presentationOptions
        self.backgroundColor = backgroundColor
 
    }
}

extension PresentationStyle {
    /// makes PresentationOptions passed to style be [.unanimated] and only that
    static func unanimated(style: PresentationStyle) -> PresentationStyle {
        return PresentationStyle(name: "unanimated-(\(style.name))") { viewController, from, _ in
            return style.present(viewController, from: from, options: [.unanimated])
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
        overlay.backgroundColor = .white
        overlay.layer.cornerRadius = 15
        overlay.clipsToBounds = true
        
        view.addSubview(overlay)
        
        let overshootHeight: CGFloat = 800
        let overlayHeight: CGFloat = 400
        
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
            ease.velocity = panGestureRecognizer.velocity(in: view).y
            ease.targetValue = overlayCenter() + location.y
        }
        
        bag += ease.addSpring(tension: 200, damping: 20, mass: 1) { position in
           overlay.center.y = position
        }
        
        bag += panGestureRecognizer.signal(forState: .ended).onValue { _ in
            ease.velocity = panGestureRecognizer.velocity(in: view).y
            ease.targetValue = overlayCenter()
        }
    
        bag += overlay.install(panGestureRecognizer)
        
        let (childScreen, childDisposable) = presentable.materialize()
        childScreen.setLargeTitleDisplayMode(presentationOptions)
        
        let embeddedChildScreen = childScreen.embededInNavigationController(presentationOptions)
        
        bag += childDisposable
        
        viewController.addChild(embeddedChildScreen)
        
        embeddedChildScreen.view.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(embeddedChildScreen.view)
        
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
                
                if translation.y > (overlayHeight / 2) || velocity.y > 1700 {
                    hideOverlay()
                }
            }
            
            bag += dimmingViewTap.signal(forState: .recognized).onValue {
                hideOverlay()
            }
            
            return bag
        })
    }
}
