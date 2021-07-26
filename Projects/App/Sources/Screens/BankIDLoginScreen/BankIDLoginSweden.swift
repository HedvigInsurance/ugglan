import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct BankIDLoginSweden {
	@Inject var client: ApolloClient
}

extension BankIDLoginSweden {
	enum AutoStartTokenError: Error {
		case failedToGenerate
	}

	enum FailedError: Error {
		case failed
	}

	func generateAutoStartToken() -> Future<URL> {
		client.perform(mutation: GraphQL.BankIdAuthMutation()).compactMap { $0.bankIdAuth.autoStartToken }
			.flatMap { autoStartToken in
				let urlScheme = Bundle.main.urlScheme ?? ""
				guard
					let url = URL(
						string:
							"bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid"
					)
				else {
					return Future(error: AutoStartTokenError.failedToGenerate)
				}

				return Future(url)
			}
	}
}

extension BankIDLoginSweden: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let viewController = UIViewController()
		viewController.preferredPresentationStyle = .detented(.large)
		let bag = DisposeBag()

		let view = UIView()
		view.backgroundColor = .brand(.primaryBackground())
		viewController.view = view
		viewController.title = L10n.bankidLoginTitle

		let containerStackView = UIStackView()
		containerStackView.axis = .vertical
		containerStackView.alignment = .center

		view.addSubview(containerStackView)

		containerStackView.snp.makeConstraints { make in
			make.leading.trailing.top.equalToSuperview()
		}

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

		iconContainerView.snp.makeConstraints { make in
			make.height.width.equalTo(120)
		}

		let imageView = UIImageView()
		imageView.image = Asset.bankIdLogo.image
		imageView.tintColor = .brand(.primaryText())

		iconContainerView.addSubview(imageView)

		imageView.snp.makeConstraints { make in
			make.height.width.equalToSuperview()
		}

		headerContainer.addArrangedSubview(iconContainerView)

		bag += headerContainer.addArranged(LoadingIndicator(showAfter: 0, size: 50).wrappedIn(UIStackView()))

		var statusLabel = MultilineLabel(value: L10n.signStartBankid, style: .brand(.headline(color: .primary)))
		bag += containerView.addArranged(statusLabel)

		let bankIDOnAnotherDeviceContainer = UIStackView()
		containerView.addArrangedSubview(bankIDOnAnotherDeviceContainer)

		let bankIDOnAnotherDeviceButton = Button(
			title: L10n.bankidOnAnotherDevice,
			type: .standardOutline(borderColor: .brand(.primaryText()), textColor: .brand(.primaryText()))
		)
		bag += bankIDOnAnotherDeviceContainer.addArranged(bankIDOnAnotherDeviceButton)

		bag += bankIDOnAnotherDeviceButton.onTapSignal.onValue({ _ in
			viewController.present(BankIDLoginQR())
		})

		let closeButtonContainer = UIStackView()
		closeButtonContainer.animationSafeIsHidden = true
		containerView.addArrangedSubview(closeButtonContainer)

		let closeButton = Button(
			title: L10n.generalCloseButton,
			type: .standard(backgroundColor: .purple, textColor: .white)
		)
		bag += closeButtonContainer.addArranged(closeButton)

		let statusSignal =
			client.subscribe(
				subscription: GraphQL.AuthStatusSubscription()
			)
			.compactMap { $0.authStatus?.status }

		bag += statusSignal.skip(first: 1)
			.onValue { authStatus in
				let statusText: String

				switch authStatus {
				case .initiated:
					statusText = L10n.bankIdAuthTitleInitiated
				case .inProgress:
					statusText = L10n.bankIdAuthTitleInitiated
				case .failed:
					statusText = L10n.bankIdAuthTitleInitiated
				case .success:
					statusText = L10n.bankIdAuthTitleInitiated
				case .__unknown:
					statusText = L10n.bankIdAuthTitleInitiated
				}

				statusLabel.value = statusText
			}

		generateAutoStartToken()
			.onValue { url in
				if UIApplication.shared.canOpenURL(url) {
					UIApplication.shared.open(url, options: [:], completionHandler: nil)
				} else {
					viewController.present(BankIDLoginQR())
				}
			}

		return (
			viewController,
			Future { completion in
				bag += closeButton.onTapSignal.onValue {
					completion(.failure(FailedError.failed))
				}

				bag += statusSignal.distinct()
					.onValue { authState in
						if authState == .success {
							let appDelegate = UIApplication.shared.appDelegate

							if let fcmToken = ApplicationState.getFirebaseMessagingToken() {
								appDelegate.registerFCMToken(fcmToken)
							}

							AnalyticsCoordinator().setUserId()

							let window = appDelegate.appFlow.window
                            bag += window.present(MainTabbedJourney.journey)
						}
					}

				return bag
			}
		)
	}
}
