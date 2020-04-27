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

enum PushNotificationsRegisterError: Error {
    case canceled
}

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
                    UIApplication.shared.appDelegate.registerForPushNotifications().onValue { _ in }
                }),
                Alert.Action(title: String(key: .PUSH_NOTIFICATIONS_ALERT_ACTION_NOT_NOW), style: .cancel, action: {
                    throw PushNotificationsRegisterError.canceled
                }),
            ]
        )

        let (viewController, future) = alert.materialize()
        return (viewController, future.flatMap { $0 })
    }
}
