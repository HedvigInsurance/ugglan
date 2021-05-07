import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct HonestyPledge {
	enum PushNotificationsAction { case ask, skip }

	func pushNotificationsPresentable() -> PresentableViewable<
		ImageTextAction<PushNotificationsAction>, PushNotificationsAction
	> {
		let pushNotificationsDoButton = Button(
			title: L10n.claimsActivateNotificationsCta,
			type: .standard(
				backgroundColor: .brand(.primaryButtonBackgroundColor),
				textColor: .brand(.primaryButtonTextColor)
			)
		)

		let pushNotificationsSkipButton = Button(
			title: L10n.claimsActivateNotificationsDismiss,
			type: .transparent(textColor: .brand(.link))
		)

		let pushNotificationsAction = ImageTextAction<PushNotificationsAction>(
			image: .init(image: Asset.activatePushNotificationsIllustration.image),
			title: L10n.claimsActivateNotificationsHeadline,
			body: L10n.claimsActivateNotificationsBody,
			actions: [(.ask, pushNotificationsDoButton), (.skip, pushNotificationsSkipButton)],
			showLogo: false
		)

		return PresentableViewable(viewable: pushNotificationsAction) { viewController in
			viewController.navigationItem.hidesBackButton = true
		}
	}
}

extension HonestyPledge: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let viewController = UIViewController()
		viewController.title = L10n.honestyPledgeTitle

		let bag = DisposeBag()

		let containerStackView = UIStackView()
		containerStackView.layoutMargins = UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15)
		containerStackView.isLayoutMarginsRelativeArrangement = true
		containerStackView.axis = .vertical
		containerStackView.distribution = .equalSpacing

		let topContentStackView = UIStackView()
		topContentStackView.axis = .vertical
		topContentStackView.spacing = 10

		containerStackView.addArrangedSubview(topContentStackView)

		let descriptionLabel = MultilineLabel(
			value: L10n.honestyPledgeDescription,
			style: .brand(.body(color: .secondary))
		)
		bag += topContentStackView.addArranged(descriptionLabel)

		let slideToClaim = SlideToClaim()
		bag += containerStackView.addArranged(slideToClaim.wrappedIn(UIStackView())) { slideToClaimStackView in
			slideToClaimStackView.isLayoutMarginsRelativeArrangement = true
		}

		let view = UIView()
		view.backgroundColor = .brand(.secondaryBackground())
		viewController.view = view

		view.addSubview(containerStackView)

		containerStackView.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

		bag += containerStackView.didLayoutSignal.onValue { _ in
			viewController.preferredContentSize = containerStackView.systemLayoutSizeFitting(.zero)
		}

		return (
			viewController,
			Future { completion in
				bag += slideToClaim.onValue {
					func presentClaimsChat() {
						viewController.present(
							ClaimsChat().withCloseButton,
							style: .detented(.large, modally: false)
						).onResult(completion)
					}

					if UIApplication.shared.isRegisteredForRemoteNotifications {
						presentClaimsChat()
					} else {
						bag += viewController.present(
							self.pushNotificationsPresentable(),
							style: .detented(.large, modally: false)
						).onValue { action in
							if action == .ask {
								UIApplication.shared.appDelegate
									.registerForPushNotifications().onValue { _ in
										presentClaimsChat()
									}
							} else {
								presentClaimsChat()
							}
						}
					}
				}

				return DelayedDisposer(bag, delay: 1)
			}
		)
	}
}
