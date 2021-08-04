//
//  ClaimsAskForPushnotifications.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-08-04.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import Flow

struct ClaimsAskForPushnotifications: Presentable {
    enum PushNotificationsAction { case ask, skip }
    
    func materialize() -> (UIViewController, Signal<Void>) {
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
        
        let (viewController, signal) = PresentableViewable(viewable: pushNotificationsAction) { viewController in
            viewController.navigationItem.hidesBackButton = true
        }.materialize()

        return (viewController, signal.flatMapLatest({ action -> Signal<Void> in
            if action == .ask {
                return UIApplication.shared.appDelegate
                    .registerForPushNotifications()
                    .valueSignal
                    .plain()
            }
            
            return Signal(after: 0)
        }))
    }
}
