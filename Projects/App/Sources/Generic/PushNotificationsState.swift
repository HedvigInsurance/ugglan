//
//  PushNotificationsState.swift
//  hedvig
//
//  Created by Sam Pettersson on 2019-06-12.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation

struct PushNotificationsState {
    static let hasAskedForActivatingPushNotificationsKey = "hasAskedForActivatingPushNotifications"

    static var hasAskedForActivatingPushNotifications: Bool {
        return UserDefaults.standard.value(forKey: hasAskedForActivatingPushNotificationsKey) as? Bool ?? false
    }

    static func didAskForPushNotifications() {
        UserDefaults.standard.set(true, forKey: hasAskedForActivatingPushNotificationsKey)
    }
}
