//
//  AppNotifications.swift
//  project
//
//  Created by Gustaf Gunér on 2019-07-11.
//

import Foundation
import Flow
import UIKit

enum AppNotificationSymbol {
    case imageAsset(_ asset: ImageAsset)
    case character(_ character: String)
    
    func getView() -> UIView {
        if case .character(let value) = self {
            let symbol = UILabel()
            symbol.text = value
            symbol.font = HedvigFonts.circularStdBook?.withSize(24)
            
            return symbol
        }
        
        if case .imageAsset(let value) = self {
            let symbol = UIImageView()
            symbol.image = value.image
            symbol.contentMode = .scaleAspectFit
            
            symbol.snp.makeConstraints { make in
                make.width.equalTo(20)
            }
            
            return symbol
        }
        
        return UIView()
    }
}

struct AppNotification {
    let symbol: AppNotificationSymbol
    let body: String
    let duration: TimeInterval
}

extension AppNotification : Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 10
        view.layer.shadowColor = UIColor.darkGray.cgColor

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 5, verticalInset: 5)
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 26, verticalInset: 15)

        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        let symbolContainer = UIStackView()
        symbolContainer.axis = .horizontal
        symbolContainer.edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        // symbolContainer.alignment = .center
        
        stackView.addArrangedSubview(symbolContainer)
        
        symbolContainer.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        let symbolView = symbol.getView()
        symbolContainer.addArrangedSubview(symbolView)
        
        let textContainer = UIStackView()
        textContainer.axis = .vertical
        
        let bodyLabel = MultilineLabel(value: body, style: .toastBody)
        bag += textContainer.addArranged(bodyLabel)
        
        stackView.addArrangedSubview(textContainer)
        
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
        stackView.edgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .center
        
        view.addSubview(stackView)
        
        bag += notificationSignal.compactMap { $0 }.onValue { notification in
            bag += stackView.addArranged(notification) { appNotificationView in
                appNotificationView.layer.opacity = 0
                appNotificationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                appNotificationView.isHidden = true
                
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
