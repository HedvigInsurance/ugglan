//
//  HonestyPledge.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct HonestyPledge {
    enum PushNotificationsAction {
        case ask, skip
    }

    func pushNotificationsPresentable() -> PresentableViewable<ImageTextAction<PushNotificationsAction>, PushNotificationsAction> {
        let pushNotificationsDoButton = Button(
            title: L10n.claimsActivateNotificationsCta,
            type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
        )

        let pushNotificationsSkipButton = Button(
            title: L10n.claimsActivateNotificationsDismiss,
            type: .transparent(textColor: .pink)
        )

        let pushNotificationsAction = ImageTextAction<PushNotificationsAction>(
            image: .init(image: Asset.activatePushNotificationsIllustration.image),
            title: L10n.claimsActivateNotificationsHeadline,
            body: L10n.claimsActivateNotificationsBody,
            actions: [
                (.ask, pushNotificationsDoButton),
                (.skip, pushNotificationsSkipButton),
            ],
            showLogo: false
        )

        return PresentableViewable(viewable: pushNotificationsAction) { viewController in
            viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 70)
        }
    }
}

extension HonestyPledge: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerStackView = UIStackView()
        containerStackView.alignment = .leading
        bag += containerStackView.applySafeAreaBottomLayoutMargin()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 10

        containerStackView.addArrangedSubview(stackView)

        let titleLabel = MultilineLabel(value: L10n.honestyPledgeTitle, style: .draggableOverlayTitle)
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: L10n.honestyPledgeDescription,
            style: .bodyOffBlack
        )
        bag += stackView.addArranged(descriptionLabel)

        let pusherView = UIView()
        pusherView.snp.makeConstraints { make in
            make.height.equalTo(10)
        }
        stackView.addArrangedSubview(pusherView)

        let slideToClaim = SlideToClaim()
        bag += stackView.addArranged(slideToClaim.wrappedIn(UIStackView())) { slideToClaimStackView in
            slideToClaimStackView.isLayoutMarginsRelativeArrangement = true
        }

        bag += containerStackView.applyPreferredContentSize(on: viewController)

        let view = UIView()
        view.backgroundColor = .secondaryBackground
        viewController.view = view

        view.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        return (viewController, Future { completion in
            bag += slideToClaim.onValue {
                func presentClaimsChat() {
                    viewController.present(
                        ClaimsChat().withCloseButton,
                        style: .default,
                        options: [.prefersNavigationBarHidden(false)]
                    ).onResult(completion)
                }

                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    presentClaimsChat()
                } else {
                    bag += viewController.present(
                        self.pushNotificationsPresentable(),
                        style: .default,
                        options: [.prefersNavigationBarHidden(true)]
                    ).onValue { action in
                        if action == .ask {
                            UIApplication.shared.appDelegate.registerForPushNotifications().onValue { _ in
                                presentClaimsChat()
                            }
                        } else {
                            presentClaimsChat()
                        }
                    }
                }
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
