//
//  Toasts.swift
//  project
//
//  Created by Gustaf Gunér on 2019-07-11.
//

import Flow
import Form
import Foundation
import UIKit

enum ToastHideDirection {
    case left
    case right
}

enum ToastSymbol: Equatable {
    static func == (lhs: ToastSymbol, rhs: ToastSymbol) -> Bool {
        switch (lhs, rhs) {
        case let (.character(lhsCharacter), .character(rhsCharacter)):
            return lhsCharacter == rhsCharacter
        case let (.icon(lhsIcon), .icon(rhsIcon)):
            return lhsIcon.image == rhsIcon.image
        default:
            return false
        }
    }

    case character(_ character: Character)
    case icon(_ icon: ImageAsset)
}

struct Toast: Equatable {
    let symbol: ToastSymbol
    let body: String
    let textColor: UIColor
    let backgroundColor: UIColor
    let duration: TimeInterval
}

extension Toast: Viewable {
    var symbolView: UIView {
        switch symbol {
        case let .character(character):
            let view = UILabel()
            view.text = String(character)
            view.font = HedvigFonts.circularStdBook?.withSize(15)
            return view
        case let .icon(icon):
            let view = UIImageView()
            view.image = icon.image
            view.contentMode = .scaleAspectFit

            view.snp.makeConstraints { make in
                make.width.equalTo(20)
            }

            return view
        }
    }

    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        containerView.backgroundColor = backgroundColor
        bag += containerView.applyShadow { trait in
            UIView.ShadowProperties(
                opacity: trait.userInterfaceStyle == .dark ? 0 : 0.15,
                offset: CGSize(width: 0, height: 0),
                radius: 10,
                color: UIColor.darkGray,
                path: nil
            )
        }

        bag += containerView.didLayoutSignal.onValue {
            containerView.layer.cornerRadius = containerView.frame.height
        }

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 26, verticalInset: 15)
        stackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }

        let symbolContainer = UIStackView()
        symbolContainer.axis = .horizontal

        stackView.addArrangedSubview(symbolContainer)

        symbolContainer.snp.makeConstraints { make in
            make.width.equalTo(30)
        }

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
    private let idleCallbacker = Callbacker<Void>()
    var idleSignal: Signal<Void> {
        return idleCallbacker.providedSignal
    }
}

extension Toasts: Viewable {
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
                            toastView.removeFromSuperview()

                            if stackView.subviews.isEmpty {
                                self.idleCallbacker.callAll()
                            }

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

                    if abs(location.x) > 80 {
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

        bag += stackView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.height.equalToSuperview()
        }

        return (containerView, bag)
    }
}
