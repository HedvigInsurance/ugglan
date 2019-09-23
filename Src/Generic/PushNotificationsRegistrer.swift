//
//  PushNotificationsRegistrer.swift
//  project
//
//  Created by Axel Backlund on 2019-07-08.
//

import Flow
import Foundation
import Presentation
import UIKit
import UserNotifications

struct PushNotificationsRegister: Presentable {
    let title: String
    let message: String
    let forceAsk: Bool

    init(title: String, message: String, forceAsk: Bool = false) {
        self.title = title
        self.message = message
        self.forceAsk = forceAsk
    }

    func materialize() -> (UIViewController?, Future<Void>) {
        guard !PushNotificationsState.hasAskedForActivatingPushNotifications || forceAsk, !UIApplication.shared.isRegisteredForRemoteNotifications else {
            return (nil, Future(()))
        }

        PushNotificationsState.didAskForPushNotifications()

        let alert = Alert(
            title: title,
            message: message,
            actions: [
                Alert.Action(title: String(key: .PUSH_NOTIFICATIONS_ALERT_ACTION_OK), action: {
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                        if settings.authorizationStatus == .denied {
                            DispatchQueue.main.async {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                    }
                    UIApplication.shared.appDelegate.registerForPushNotifications().onValue { _ in }
                }),
                Alert.Action(title: String(key: .PUSH_NOTIFICATIONS_ALERT_ACTION_NOT_NOW), action: {
                    ()
                }),
            ]
        )

        let (viewController, future) = alert.materialize()
        return (viewController, future)
    }
}
