//
//  Toasts.swift
//  project
//
//  Created by Gustaf Gunér on 2019-07-11.
//

import Foundation
import Flow
import Form
import UIKit

enum ToastHideDirection {
    case left
    case right
}

typealias ToastSymbol = Either<Character, ImageAsset>

struct Toast {
    let symbol: ToastSymbol
    let body: String
    let textColor: UIColor
    let backgroundColor: UIColor
    let duration: TimeInterval
}

extension Toast : Viewable {
    func getView() -> UIView {
        if let character = symbol.left {
            let view = UILabel()
            view.text = String(character)
            view.font = HedvigFonts.circularStdBook?.withSize(24)
            
            return view
        } else {
            let imageAsset = symbol.right!
            
            let view = UIImageView()
            view.image = imageAsset.image
            view.contentMode = .scaleAspectFit
            
            view.snp.makeConstraints { make in
                make.width.equalTo(20)
            }
            
            return view
        }
    }
    
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
        symbolContainer.edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: symbol.left != nil ? 6 : 16)
        
        stackView.addArrangedSubview(symbolContainer)
        
        symbolContainer.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        let symbolView = getView()
        
        symbolContainer.addArrangedSubview(symbolView)
        
        let textContainer = UIStackView()
        textContainer.axis = .vertical
        
        let bodyLabel = MultilineLabel(value: body, style: TextStyle.toastBody.colored(textColor))
        bag += textContainer.addArranged(bodyLabel)
        
        stackView.addArrangedSubview(textContainer)
        
        return (containerView, bag)
    }
}

struct Toasts {
    let toastSignal: ReadWriteSignal<Toast?>
}

extension Toasts : Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let containerView = UIStackView()
        
        let stackView = UIStackView()
        stackView.edgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .center
        
        containerView.addArrangedSubview(stackView)
        
        bag += toastSignal.compactMap { $0 }.onValue { toast in
            bag += stackView.addArranged(toast) { toastView in
                toastView.layer.opacity = 0
                toastView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                toastView.isHidden = true
                
                let innerBag = bag.innerBag()
                
                let pauseSignal = ReadWriteSignal<Bool>(false)
                
                let panGestureRecognizer = UIPanGestureRecognizer()
                innerBag += toastView.install(panGestureRecognizer)
                
                innerBag += panGestureRecognizer.signal(forState: .began).onValue {
                    pauseSignal.value = true
                }
                
                innerBag += panGestureRecognizer.signal(forState: .changed).onValue {
                    let location = panGestureRecognizer.translation(in: toastView)
                    toastView.layer.opacity = Float(1 - (abs(location.x) / (UIScreen.main.bounds.width / 2)))
                    toastView.transform = CGAffineTransform(translationX: location.x, y: 0)
                }
                
                innerBag += Signal(after: 0).feedback(type: .impactMedium)
                
                innerBag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.15)) { _ in
                    toastView.isHidden = false
                }.animated(style: SpringAnimationStyle.heavyBounce(delay: 0, duration: 0.3)) { _ in
                    toastView.layer.opacity = 1
                    toastView.transform = CGAffineTransform.identity
                }
                
                let hideBag = DisposeBag()
                
                func hideToast(direction: ToastHideDirection = .left) {
                    hideBag += Signal(after: 0)
                        .animated(style: AnimationStyle.easeOut(duration: 0.3)) { _ in
                            toastView.layer.opacity = 0
                            toastView.transform = CGAffineTransform(translationX: (direction == .left ? -1 : 1) * toastView.frame.width, y: 0)
                        }.animated(style: AnimationStyle.easeOut(duration: 0.15)) { _ in
                            toastView.isHidden = true
                        }.onValue { _ in
                            stackView.removeArrangedSubview(toastView)
                            innerBag.dispose()
                    }
                }
                
                let hideAction = Signal(after: toast.duration).onValue { _ in
                    hideToast()
                }
                
                hideBag += hideAction
                innerBag += hideBag
                
                innerBag += panGestureRecognizer.signal(forState: .ended).onValue {
                    let location = panGestureRecognizer.translation(in: toastView)
                    
                    if (abs(location.x) > 80) {
                        hideAction.dispose()
                        hideToast(direction: location.x < 0 ? .left : .right)
                    } else {
                        innerBag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.2)) { _ in
                            toastView.layer.opacity = 1
                            toastView.transform = CGAffineTransform(translationX: 0, y: 0)
                        }
                    }
                    pauseSignal.value = false
                }
                
                innerBag += pauseSignal.distinct().onValue { pause in
                    if pause {
                        hideBag.dispose()
                    } else {
                        hideBag += Signal(after: 3).onValue { _ in
                            hideToast()
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
