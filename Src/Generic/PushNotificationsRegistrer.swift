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

struct PushNotificationsRegister: Presentable {
    let title: String
    let message: String
    
    func materialize() -> (UIViewController, Future<Void>) {
        guard !PushNotificationsState.hasAskedForActivatingPushNotifications, !UIApplication.shared.isRegisteredForRemoteNotifications else {
            let emptyViewController = UIViewController()
            emptyViewController.preferredPresentationStyle = .modally(
                presentationStyle: .overCurrentContext,
                transitionStyle: .none,
                capturesStatusBarAppearance: nil
            )
            return (emptyViewController, Future(()))
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
        
        return alert.materialize()
    }
}
