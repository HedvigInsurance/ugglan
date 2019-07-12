//
//  PushNotificationsRegistrer.swift
//  project
//
//  Created by Axel Backlund on 2019-07-08.
//

import Foundation
import Flow
import Presentation
import UIKit

struct PushNotificationsRegistrer {
    static func ask(title: String, message: String, viewController: UIViewController) {
        guard !PushNotificationsState.hasAskedForActivatingPushNotifications else {
            return
        }
        guard !UIApplication.shared.isRegisteredForRemoteNotifications else {
            return
        }
        
        PushNotificationsState.didAskForPushNotifications()
        
        let alert = Alert(
            title: title,
            message: message,
            actions: [
                Alert.Action(title: String(key: .PUSH_NOTIFICATIONS_ALERT_ACTION_OK), action: {
                    UIApplication.shared.appDelegate.registerForPushNotifications()
                }),
                Alert.Action(title: String(key: .PUSH_NOTIFICATIONS_ALERT_ACTION_NOT_NOW), action: {})
            ]
        )
        
        viewController.present(alert)
    }
}
