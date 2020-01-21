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

struct HonestyPledge {
    enum PushNotificationsAction {
        case ask, skip
    }
    
    func pushNotificationsPresentable() -> PresentableViewable<ImageTextAction<PushNotificationsAction>, PushNotificationsAction> {
        let pushNotificationsDoButton = Button(
            title: String(key: .CLAIMS_ACTIVATE_NOTIFICATIONS_CTA),
            type: .standard(backgroundColor: .primaryTintColor, textColor: .white)
        )

        let pushNotificationsSkipButton = Button(
            title: String(key: .CLAIMS_ACTIVATE_NOTIFICATIONS_DISMISS),
            type: .transparent(textColor: .pink)
        )
        
        let pushNotificationsAction = ImageTextAction<PushNotificationsAction>(
            image: Asset.activatePushNotificationsIllustration.image,
            title: String(key: .CLAIMS_ACTIVATE_NOTIFICATIONS_HEADLINE),
            body: String(key: .CLAIMS_ACTIVATE_NOTIFICATIONS_BODY),
            actions: [
               (.ask, pushNotificationsDoButton),
               (.skip, pushNotificationsSkipButton),
            ],
            showLogo: false
        )

        return PresentableViewable(viewable: pushNotificationsAction) {
            let viewController = UIViewController()
            viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 70)
            return viewController
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

        let titleLabel = MultilineLabel(value: String(key: .HONESTY_PLEDGE_TITLE), style: .draggableOverlayTitle)
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .HONESTY_PLEDGE_DESCRIPTION),
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

        viewController.view = containerStackView
           

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
