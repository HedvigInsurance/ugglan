import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

enum MessageType {
    case received, replied
}

struct MessageBubble {
    let textSignal: ReadWriteSignal<String>
    let delay: TimeInterval
    let animationDelay: TimeInterval
    let animated: Bool
    let messageType: MessageType

    init(text: String, delay: TimeInterval, animated: Bool = false, animationDelay: TimeInterval = 0, messageType: MessageType = .received) {
        self.delay = delay
        textSignal = ReadWriteSignal(text)
        self.animated = animated
        self.animationDelay = animationDelay
        self.messageType = messageType
    }
}

extension MessageBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerStackView = UIStackView()
        containerStackView.axis = .horizontal
        containerStackView.alignment = .leading
        containerStackView.isHidden = true

        let stylingView = UIView()
        bag += stylingView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.05,
                offset: CGSize(width: 0, height: 6),
                radius: 8,
                color: .brand(.primaryShadowColor),
                path: nil
            )
        }
        stylingView.alpha = 0

        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.insetsLayoutMarginsFromSafeArea = false
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)

        let bodyStyle: TextStyle = messageType == .replied ? .brand(.body(color: .primary(state: .negative))) : .brand(.body(color: .primary))

        let label = MultilineLabel(value: "", style: bodyStyle, usePreferredMaxLayoutWidth: false)
        bag += containerView.addArranged(label) { labelView in
            bag += labelView.copySignal.onValue { _ in
                UIPasteboard.general.string = labelView.text
            }

            labelView.alpha = 0

            if animated {
                bag += textSignal
                    .atOnce()
                    .map { StyledText(text: $0, style: bodyStyle) }
                    .delay(by: delay)
                    .onValue { styledText in
                        UIView.performWithoutAnimation {
                            label.styledTextSignal.value = styledText
                            containerStackView.isHidden = false
                            stylingView.alpha = 1
                            labelView.alpha = 1
                        }
                    }
            } else {
                bag += textSignal
                    .atOnce()
                    .map { StyledText(text: $0, style: bodyStyle) }
                    .onValue { styledText in
                        label.styledTextSignal.value = styledText
                        containerStackView.isHidden = false
                        stylingView.alpha = 1
                        labelView.alpha = 1
                    }
            }
        }

        stylingView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
            make.width.lessThanOrEqualTo(300)
        }

        stylingView.backgroundColor = .brand(.secondaryBackground(messageType == .replied))
        stylingView.layer.cornerRadius = 10

        if messageType == .replied {
            bag += containerStackView.didLayoutSignal.take(first: 1).onValue { _ in
                let pushView = UIView()
                pushView.snp.makeConstraints { make in
                    make.height.equalTo(50)
                }
                pushView.setContentHuggingPriority(.defaultLow, for: .horizontal)
                containerStackView.insertArrangedSubview(pushView, at: 0)

                containerStackView.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                }
            }
        }

        containerStackView.addArrangedSubview(stylingView)

        if animated {
            bag += containerStackView.didLayoutSignal.take(first: 1).onValue { _ in
                containerStackView.transform = CGAffineTransform.identity
                containerStackView.transform = CGAffineTransform(translationX: 0, y: 40)
                containerStackView.alpha = 0

                bag += Signal(after: 0.1 + Double(self.animationDelay) * 0.1).animated(style: .lightBounce(), animations: { _ in
                    containerStackView.transform = CGAffineTransform.identity
                    containerStackView.alpha = 1
                })
            }
        }

        return (containerStackView, bag)
    }
}
