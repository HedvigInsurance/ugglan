//
//  AppNotifications.swift
//  project
//
//  Created by Gustaf Gunér on 2019-07-11.
//

import Foundation
import Flow
import Form
import UIKit

enum AppNotificationSymbol {
    case character(_ character: String)
    case imageAsset(_ asset: ImageAsset)
    
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
    
    func getContainerEdgeInsets() -> UIEdgeInsets {
        switch self {
        case .character((_)):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        case .imageAsset((_)):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        }
    }
}

enum NotificationHideDirection {
    case left
    case right
}

struct AppNotification {
    let symbol: AppNotificationSymbol
    let body: String
    let textColor: UIColor
    let backgroundColor: UIColor
    let duration: TimeInterval
}

extension AppNotification : Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let containerView = UIView()
        
        containerView.backgroundColor = backgroundColor
        containerView.layer.cornerRadius = 30
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowColor = UIColor.darkGray.cgColor

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 5, verticalInset: 5)
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 26, verticalInset: 15)

        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        let symbolContainer = UIStackView()
        symbolContainer.axis = .horizontal
        symbolContainer.edgeInsets = symbol.getContainerEdgeInsets()
        
        stackView.addArrangedSubview(symbolContainer)
        
        symbolContainer.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        let symbolView = symbol.getView()
        symbolContainer.addArrangedSubview(symbolView)
        
        let textContainer = UIStackView()
        textContainer.axis = .vertical
        
        let bodyLabel = MultilineLabel(value: body, style: TextStyle.toastBody.colored(textColor))
        bag += textContainer.addArranged(bodyLabel)
        
        stackView.addArrangedSubview(textContainer)
        
        return (containerView, bag)
    }
}

struct AppNotifications {
    let notificationSignal: ReadWriteSignal<AppNotification?>
}

extension AppNotifications : Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let containerView = UIStackView()
        
        let stackView = UIStackView()
        stackView.edgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .center
        
        containerView.addArrangedSubview(stackView)
        
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
                    appNotificationView.layer.opacity = Float(1 - (abs(location.x) / (UIScreen.main.bounds.width / 2)))
                    appNotificationView.transform = CGAffineTransform(translationX: location.x, y: 0)
                }
                
                innerBag += Signal(after: 0).feedback(type: .impactMedium)
                
                innerBag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.15)) { _ in
                    appNotificationView.isHidden = false
                }.animated(style: SpringAnimationStyle.heavyBounce(delay: 0, duration: 0.3)) { _ in
                    appNotificationView.layer.opacity = 1
                    appNotificationView.transform = CGAffineTransform.identity
                }
                
                let hideBag = DisposeBag()
                
                func hideNotification(direction: NotificationHideDirection = .left) {
                    hideBag += Signal(after: 0)
                        .animated(style: AnimationStyle.easeOut(duration: 0.3)) { _ in
                            appNotificationView.layer.opacity = 0
                            appNotificationView.transform = CGAffineTransform(translationX: (direction == .left ? -1 : 1) * appNotificationView.frame.width, y: 0)
                        }.animated(style: AnimationStyle.easeOut(duration: 0.15)) { _ in
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
                    
                    if (abs(location.x) > 80) {
                        hideAction.dispose()
                        hideNotification(direction: location.x < 0 ? .left : .right)
                    } else {
                        innerBag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.2)) { _ in
                            appNotificationView.layer.opacity = 1
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
        
        return (containerView, bag)
    }
}
