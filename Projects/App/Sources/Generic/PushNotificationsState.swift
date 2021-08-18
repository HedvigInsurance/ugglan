import Flow
import Foundation
import Presentation

struct PushNotificationsState {
  static let hasAskedForActivatingPushNotificationsKey = "hasAskedForActivatingPushNotifications"

  static var hasAskedForActivatingPushNotifications: Bool {
    UserDefaults.standard.value(forKey: hasAskedForActivatingPushNotificationsKey) as? Bool ?? false
  }

  static func didAskForPushNotifications() {
    UserDefaults.standard.set(true, forKey: hasAskedForActivatingPushNotificationsKey)
  }
}
