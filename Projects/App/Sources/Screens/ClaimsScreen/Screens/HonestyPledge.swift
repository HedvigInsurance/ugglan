//
//  HonestyPledge.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

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
        containerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.axis = .vertical
        containerStackView.distribution = .equalSpacing

        let topContentStackView = UIStackView()
        topContentStackView.axis = .vertical
        topContentStackView.spacing = 10

        containerStackView.addArrangedSubview(topContentStackView)

        let titleLabel = MultilineLabel(value: L10n.honestyPledgeTitle, style: .draggableOverlayTitle)
        bag += topContentStackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: L10n.honestyPledgeDescription,
            style: .bodyOffBlack
        )
        bag += topContentStackView.addArranged(descriptionLabel)

        let slideToClaim = SlideToClaim()
        bag += containerStackView.addArranged(slideToClaim.wrappedIn(UIStackView())) { slideToClaimStackView in
            slideToClaimStackView.isLayoutMarginsRelativeArrangement = true
        }

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
                        style: .detented(.large, modally: false),
                        options: [.prefersNavigationBarHidden(false)]
                    ).onResult(completion)
                }

                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    presentClaimsChat()
                } else {
                    bag += viewController.present(
                        self.pushNotificationsPresentable(),
                        style: .detented(.large, modally: false),
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
