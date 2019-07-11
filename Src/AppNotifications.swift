//
//  AppNotifications.swift
//  project
//
//  Created by Gustaf Gunér on 2019-07-11.
//

import Foundation
import Flow
import UIKit

struct AppNotification {
    let body: String
    let duration: TimeInterval
    
    init(body: String, duration: TimeInterval) {
        self.body = body
        self.duration = duration
    }
}

extension AppNotification : Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 8
        view.layer.shadowColor = UIColor.darkGray.cgColor
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        let text = MultilineLabel(value: body, style: .bodyOffBlack)
        
        bag += stackView.addArranged(text)
        
        return (view, bag)
    }
}

struct AppNotifications {
    let notificationSignal: ReadWriteSignal<AppNotification?>
}

extension AppNotifications : Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIView()
        
        let stackView = UIStackView()
        stackView.edgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        bag += notificationSignal.compactMap { $0 }.onValue { notification in
            bag += stackView.addArranged(notification, atIndex: 0) { appNotificationView in
                appNotificationView.layer.opacity = 0
                appNotificationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                appNotificationView.isHidden = true
                
                appNotificationView.snp.makeConstraints { make in
                    make.width.equalToSuperview().inset(16)
                    make.height.equalTo(66)
                }
                
                let innerBag = bag.innerBag()
                
                let pauseSignal = ReadWriteSignal<Bool>(false)
                
                let panGestureRecognizer = UIPanGestureRecognizer()
                innerBag += appNotificationView.install(panGestureRecognizer)
                
                innerBag += panGestureRecognizer.signal(forState: .began).onValue {
                    pauseSignal.value = true
                }
                
                innerBag += panGestureRecognizer.signal(forState: .changed).onValue {
                    let location = panGestureRecognizer.translation(in: appNotificationView)
                    appNotificationView.transform = CGAffineTransform(translationX: location.x, y: 0)
                }
                
                innerBag += Signal(after: 0).feedback(type: .impactMedium)
                
                innerBag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.2)) { _ in
                    appNotificationView.isHidden = false
                }.animated(style: SpringAnimationStyle.heavyBounce()) { _ in
                    appNotificationView.layer.opacity = 1
                    appNotificationView.transform = CGAffineTransform.identity
                }
                
                let hideBag = DisposeBag()
                
                func hideNotification() {
                    hideBag += Signal(after: 0)
                        .animated(style: AnimationStyle.easeOut(duration: 0.5)) { _ in
                            appNotificationView.layer.opacity = 0
                            appNotificationView.transform = CGAffineTransform(translationX: -appNotificationView.frame.width, y: 0)
                        }.animated(style: AnimationStyle.easeOut(duration: 0.2)) { _ in
                            appNotificationView.isHidden = true
                        }.onValue { _ in
                            stackView.removeArrangedSubview(appNotificationView)
                            innerBag.dispose()
                    }
                }
                
                let hideAction = Signal(after: notification.duration).onValue { _ in
                    hideNotification()
                }
                
                hideBag += hideAction
                innerBag += hideBag
                
                innerBag += panGestureRecognizer.signal(forState: .ended).onValue {
                    let location = panGestureRecognizer.translation(in: appNotificationView)
                    if (location.x <= -80) {
                        hideAction.dispose()
                        hideNotification()
                    } else {
                        innerBag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.2)) { _ in
                            appNotificationView.transform = CGAffineTransform(translationX: 0, y: 0)
                        }
                    }
                    pauseSignal.value = false
                }
                
                innerBag += pauseSignal.distinct().onValue { pause in
                    if pause {
                        hideBag.dispose()
                    } else {
                        hideBag += Signal(after: 3).onValue { _ in
                            hideNotification()
                        }
                    }
                }
            }
        }
        
        bag += stackView.makeConstraints(wasAdded: events.wasAdded).onValue { make, safeArea in
            make.width.height.equalToSuperview()
        }
        
        return (view, bag)
    }
}
