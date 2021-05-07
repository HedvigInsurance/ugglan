import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

enum MessageType { case received, replied }

struct MessageBubble {
	let textSignal: ReadWriteSignal<String>
	let delay: TimeInterval
	let animationDelay: TimeInterval
	let animated: Bool
	let messageType: MessageType
	let pills: [String]

	init(
		text: String,
		delay: TimeInterval,
		animated: Bool = false,
		animationDelay: TimeInterval = 0,
		messageType: MessageType = .received,
		pills: [String] = []
	) {
		self.delay = delay
		textSignal = ReadWriteSignal(text)
		self.animated = animated
		self.animationDelay = animationDelay
		self.messageType = messageType
		self.pills = pills
	}
}

extension MessageBubble: Viewable {
	func itemView(value: String) -> UIView {
		let label = UILabel(value: "", style: .brand(.body(color: .primary(state: .positive))))
		let backgroundView = UIView()
		backgroundView.layer.borderWidth = 1.0
		backgroundView.layer.borderColor = UIColor.brand(.primaryBorderColor).cgColor
		backgroundView.layer.cornerRadius = 6
		backgroundView.addSubview(label)
		label.snp.makeConstraints { make in make.edges.equalToSuperview().inset(10) }
		label.text = value
		return backgroundView
	}

	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()

		let containerStackView = UIStackView()
		containerStackView.axis = .vertical
		containerStackView.alignment = messageType == .received ? .leading : .trailing
		containerStackView.isHidden = true

		let stylingView = UIView()
		bag += stylingView.applyShadow { _ in
			UIView.ShadowProperties(
				opacity: 0.05,
				offset: CGSize(width: 0, height: 6),
				blurRadius: 3,
				color: .brand(.primaryShadowColor),
				path: nil,
				radius: 8
			)
		}
		stylingView.alpha = 0

		let containerView = UIStackView()
		containerView.axis = .vertical
		containerView.isLayoutMarginsRelativeArrangement = true
		containerView.insetsLayoutMarginsFromSafeArea = false
		containerView.layoutMargins = UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 15)

		let bodyStyle = TextStyle.brand(
			.body(color: messageType == .replied ? .primary(state: .positive) : .primary)
		)

		let label = MarkdownTextView(
			textSignal: textSignal,
			style: bodyStyle,
			linkColor: messageType == .received ? UIColor.brand(.link) : bodyStyle.color
		)
		bag += containerView.addArranged(label) { labelView in
			bag += labelView.copySignal.onValue { _ in UIPasteboard.general.string = labelView.text }

			labelView.alpha = 0

			if animated {
				bag += textSignal.atOnce().delay(by: delay).onValue { _ in
					UIView.performWithoutAnimation {
						containerStackView.isHidden = false
						stylingView.alpha = 1
						labelView.alpha = 1
						labelView.layoutIfNeeded()
						labelView.layoutSuperviewsIfNeeded()
					}
				}
			} else {
				bag += textSignal.atOnce().onValue { _ in containerStackView.isHidden = false
					stylingView.alpha = 1
					labelView.alpha = 1
				}
			}
		}

		let pillStack = UIStackView()
		pillStack.axis = .vertical
		pillStack.spacing = 8
		pillStack.alignment = .leading

		pills.forEach { value in pillStack.addArrangedSubview(itemView(value: value)) }

		if !pills.isEmpty {
			pillStack.addArrangedSubview(.init(height: 5))
			containerView.addArrangedSubview(pillStack)
		}

		stylingView.addSubview(containerView)

		containerView.snp.makeConstraints { make in make.top.bottom.left.right.equalToSuperview()
			make.width.lessThanOrEqualTo(300)
		}

		stylingView.backgroundColor = .brand(.embarkMessageBubble(messageType == .replied))
		stylingView.layer.cornerRadius = 10

		if messageType == .replied {
			bag += containerStackView.didLayoutSignal.take(first: 1).onValue { _ in let pushView = UIView()
				pushView.snp.makeConstraints { make in make.height.equalTo(20) }
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

				bag += Signal(after: 0.1 + Double(self.animationDelay) * 0.1).animated(
					style: .lightBounce(),
					animations: { _ in containerStackView.transform = CGAffineTransform.identity
						containerStackView.alpha = 1
					}
				)
			}
		}

		return (containerStackView, bag)
	}
}
