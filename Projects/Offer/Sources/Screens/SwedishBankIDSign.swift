import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SwedishBankIdSign {
	@Inject var state: OldOfferState

	func presentFailedAlert(
		_ viewController: UIViewController,
		completion: @escaping (_ result: Flow.Result<Void>) -> Void
	) {
		let alert = Alert<Void>(
			title: L10n.bankidFailedTitle,
			message: L10n.bankidFailedMessage,
			actions: [
				Alert.Action(
					title: L10n.alertOk,
					action: { _ in
						completion(
							.failure(
								SwedishBankIdSignError
									.failed
							)
						)
					}
				)
			]
		)

		viewController.present(alert)
	}

	func presentErrorAlert(
		_ viewController: UIViewController,
		code: String,
		completion: @escaping (_ result: Flow.Result<Void>) -> Void
	) {
		if code == "userCancel" {
			let alert = Alert<Void>(
				title: L10n.bankidUserCancelTitle,
				message: L10n.bankidUserCancelMessage,
				actions: [
					Alert.Action(
						title: L10n.alertOk,
						action: { _ in
							completion(
								.failure(
									SwedishBankIdSignError
										.failed
								)
							)
						}
					)
				]
			)

			viewController.present(alert)
		} else if code == "expiredTransaction" {
			let alert = Alert<Void>(
				title: L10n.bankidInactiveTitle,
				message: L10n.bankidInactiveMessage,
				actions: [
					Alert.Action(
						title: L10n.bankidInactiveButton,
						action: { _ in
							completion(
								.failure(
									SwedishBankIdSignError
										.failed
								)
							)
						}
					)
				]
			)

			viewController.present(alert)
		} else {
			presentFailedAlert(viewController, completion: completion)
		}
	}
}

enum SwedishBankIdSignError: Error {
	case failed
	case userCancel
}

extension SwedishBankIdSign: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let viewController = UIViewController()
		if #available(iOS 13.0, *) {
			viewController.isModalInPresentation = true
		}

		let bag = DisposeBag()

		let view = UIView()
		view.backgroundColor = .brand(.secondaryBackground())
		viewController.view = view

		let containerStackView = UIStackView()
		containerStackView.axis = .vertical
		containerStackView.alignment = .center
		view.addSubview(containerStackView)

		containerStackView.snp.makeConstraints { make in make.leading.trailing.top.equalToSuperview() }

		let containerView = UIStackView()
		containerView.spacing = 15
		containerView.axis = .vertical
		containerView.alignment = .center
		containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
		containerView.isLayoutMarginsRelativeArrangement = true
		containerStackView.addArrangedSubview(containerView)

		let headerContainer = UIStackView()
		headerContainer.axis = .vertical
		headerContainer.spacing = 15

		containerView.addArrangedSubview(headerContainer)

		let iconContainerView = UIView()

		iconContainerView.snp.makeConstraints { make in make.height.width.equalTo(120) }

		let imageView = UIImageView()
		imageView.image = hCoreUIAssets.bankIdLogo.image
		imageView.tintColor = .brand(.primaryText())

		iconContainerView.addSubview(imageView)

		imageView.snp.makeConstraints { make in make.height.width.equalToSuperview() }

		headerContainer.addArrangedSubview(iconContainerView)

		let loaderStackView = UIStackView()
		bag += headerContainer.addArranged(LoadingIndicator(showAfter: 0, size: 50).wrappedIn(loaderStackView))

		var statusLabel = MultilineLabel(value: L10n.signStartBankid, style: .brand(.headline(color: .primary)))
		bag += containerView.addArranged(statusLabel)

		bag += containerStackView.didLayoutSignal.onValue { _ in
			viewController.preferredContentSize = containerStackView.systemLayoutSizeFitting(.zero)
		}

		return (
			viewController,
			Future { completion in
				let cancelButton = UIBarButtonItem(
					title: L10n.NavBar.cancel,
					style: .brand(.body(color: .primary))
				)

				bag += cancelButton.onValue({ _ in
					completion(.failure(SwedishBankIdSignError.userCancel))
				})

				viewController.navigationItem.rightBarButtonItem = cancelButton

				let store: OfferStore = get()
                store.send(.startSign)
            
                bag += store.stateSignal.compactMap { $0.swedishBankIDAutoStartToken }.onFirstValue { autoStartToken in
                    let urlScheme = Bundle.main.urlScheme ?? ""
                    guard
                        let url = URL(
                            string:
                                "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid"
                        )
                    else { return }

                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(
                            url,
                            options: [:],
                            completionHandler: nil
                        )
                    }
                }
            
            bag += store.onAction(.sign(event: .failed), {
                presentErrorAlert(viewController, code: store.state.swedishBankIDStatusCode ?? "", completion: completion)
            })
            
            bag += store.stateSignal.compactMap { $0.swedishBankIDStatusCode }.onValue { statusCode in
                let statusText: String

                switch statusCode {
                case "noClient", "outstandingTransaction":
                    statusText = L10n.signStartBankid
                case "userSign":
                    viewController.navigationItem
                        .rightBarButtonItem = nil
                    statusText = L10n.signInProgress
                case "userCancel", "cancelled":
                    statusText = L10n.signCanceled
                default:
                    statusText =
                        L10n.signFailedReasonUnknown
                }

                statusLabel.value = statusText
            }

				return DelayedDisposer(bag, delay: 2)
			}
		)
	}
}
