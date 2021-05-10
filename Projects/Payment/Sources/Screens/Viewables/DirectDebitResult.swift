import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

enum DirectDebitResultType {
	case success(setupType: PaymentSetup.SetupType)
	case failure(setupType: PaymentSetup.SetupType)

	var icon: ImageAsset {
		switch self {
		case .success: return hCoreUIAssets.circularCheckmark
		case .failure: return hCoreUIAssets.warningTriangle
		}
	}

	var isSuccess: Bool {
		switch self {
		case .success: return true
		case .failure: return false
		}
	}

	var headingText: String {
		switch self {
		case .success: return L10n.PayInConfirmation.headline
		case .failure: return L10n.PayInError.headline
		}
	}

	var messageText: String? {
		switch self {
		case .success: return nil
		case .failure: return L10n.PayInErrorDirectDebit.body
		}
	}

	var mainButtonText: String {
		switch self {
		case .success: return L10n.PayInConfirmation.continueButton
		case .failure: return L10n.PayInError.retryButton
		}
	}
}

struct DirectDebitResult {
	enum ResultError: Error { case retry }

	let type: DirectDebitResultType
}

extension DirectDebitResult: Viewable {
	func materialize(events: ViewableEvents) -> (UIView, Future<Void>) {
		let containerView = UIView()
		containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		containerView.alpha = 0

		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.spacing = 15

		containerView.addSubview(stackView)

		stackView.snp.makeConstraints { make in make.center.equalToSuperview()
			make.width.lessThanOrEqualToSuperview()
		}

		let bag = DisposeBag()

		let icon = Icon(frame: .zero, icon: type.icon.image, iconWidth: 40)
		stackView.addArrangedSubview(icon)

		let heading = MultilineLabel(value: type.headingText, style: .brand(.title2(color: .primary)))

		bag += stackView.addArranged(heading)

		if let messageText = type.messageText {
			let body = MultilineLabel(
				value: messageText,
				style: TextStyle.brand(.body(color: .secondary)).centerAligned
			)

			bag += stackView.addArranged(body)
		}

		let buttonsContainer = UIStackView()
		buttonsContainer.axis = .vertical
		buttonsContainer.spacing = 8
		buttonsContainer.layoutMargins = UIEdgeInsets(inset: 15)
		buttonsContainer.isLayoutMarginsRelativeArrangement = true

		containerView.addSubview(buttonsContainer)

		buttonsContainer.snp.makeConstraints { make in
			make.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom)
			make.width.equalToSuperview()
		}

		bag += containerView.didMoveToWindowSignal.take(first: 1)
			.animated(style: SpringAnimationStyle.heavyBounce()) {
				containerView.alpha = 1
				containerView.transform = CGAffineTransform.identity
			}

		bag += events.removeAfter.set { _ in 1 }

		return (
			containerView,
			Future { completion in
				if self.type.isSuccess {
					let continueButton = Button(
						title: self.type.mainButtonText,
						type: .standard(
							backgroundColor: .brand(.secondaryButtonBackgroundColor),
							textColor: .brand(.secondaryButtonTextColor)
						)
					)

					bag += continueButton.onTapSignal.onValue { _ in completion(.success) }

					bag += buttonsContainer.addArranged(continueButton)
				} else {
					let retryButton = Button(
						title: self.type.mainButtonText,
						type: .standard(
							backgroundColor: .brand(.secondaryButtonBackgroundColor),
							textColor: .brand(.secondaryButtonTextColor)
						)
					)

					bag += retryButton.onTapSignal.onValue { _ in
						bag += Signal(after: 0)
							.animated(style: SpringAnimationStyle.lightBounce()) { _ in
								containerView.transform = CGAffineTransform(
									scaleX: 0.5,
									y: 0.5
								)
								containerView.alpha = 0
								buttonsContainer.alpha = 0
							}

						completion(.failure(DirectDebitResult.ResultError.retry))
					}

					bag += buttonsContainer.addArranged(retryButton)

					let skipButton = Button(
						title: L10n.PayInError.postponeButton,
						type: .standardOutline(
							borderColor: .brand(.primaryText()),
							textColor: .brand(.primaryText())
						)
					)

					bag += skipButton.onTapSignal.onValue { _ in completion(.success) }

					bag += buttonsContainer.addArranged(skipButton)
				}

				return DelayedDisposer(bag, delay: 1)
			}
		)
	}
}
