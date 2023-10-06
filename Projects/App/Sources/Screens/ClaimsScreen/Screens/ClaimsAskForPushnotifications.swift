import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct ClaimsAskForPushnotifications: Presentable {
    enum PushNotificationsAction { case ask, skip }

    func materialize() -> (UIViewController, Signal<Void>) {
        let pushNotificationsDoButton = Button(
            title: L10n.claimsActivateNotificationsCta,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        let pushNotificationsSkipButton = Button(
            title: L10n.claimsActivateNotificationsDismiss,
            type: .transparent(textColor: .brandNew(.primaryText()))
        )

        let pushNotificationsAction = ImageTextAction<PushNotificationsAction>(
            image: .init(
                image: hCoreUIAssets.activatePushNotificationsIllustration.image,
                size: CGSize(width: CGFloat.infinity, height: 200),
                contentMode: .scaleAspectFit
            ),
            title: L10n.claimsActivateNotificationsHeadline,
            body: L10n.claimsActivateNotificationsBody,
            actions: [(.ask, pushNotificationsDoButton), (.skip, pushNotificationsSkipButton)],
            showLogo: false
        )

        let (viewController, signal) = PresentableViewable(viewable: pushNotificationsAction) {
            viewController in
            viewController.navigationItem.hidesBackButton = true
        }
        .materialize()

        return (
            viewController,
            signal.flatMapLatest({ action -> Signal<Void> in
                if action == .ask {
                    return UIApplication.shared.appDelegate
                        .registerForPushNotifications()
                        .valueSignal
                        .plain()
                }

                return Signal(after: 0)
            })
        )
    }
}
