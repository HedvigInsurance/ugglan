import Apollo
import Chat
import Contracts
import CoreDependencies
import Flow
import Foundation
import Home
import Payment
import Presentation
import Profile
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension AppDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let client: NotificationClient = Dependencies.shared.resolve()
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        client.register(for: deviceTokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.info("Failed to register for remote notifications with error: \(error))")
    }

    func observeNotificationsSettings() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { _ in
                UNUserNotificationCenter.current()
                    .getNotificationSettings { settings in
                        let store: ProfileStore = globalPresentableStoreContainer.get()
                        store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
                    }
            }
        )
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                let store: ProfileStore = globalPresentableStoreContainer.get()
                store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
            }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    fileprivate func performPushAction(notificationType: String, userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: .handlePushNotification,
            object: PushNotificationType(rawValue: notificationType.uppercased()),
            userInfo: userInfo
        )
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let notificationType = (userInfo["TYPE"] as? String) ?? (userInfo["type"] as? String) else { return }

        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            performPushAction(notificationType: notificationType, userInfo: userInfo)
        }

        completionHandler()
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler _: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let toast = ToastBar(
            type: .info,
            text: notification.request.content.title,
            action: .init(
                actionText: "Open message",
                onClick: {
                    let userInfo = notification.request.content.userInfo
                    guard let notificationType = userInfo["TYPE"] as? String else { return }

                    self.performPushAction(notificationType: notificationType, userInfo: userInfo)
                }
            )
        )
        if !HomeNavigationViewModel.isChatPresented { Toasts.shared.displayToastBar(toast: toast) }
    }

}

enum PushNotificationType: String {
    case NEW_MESSAGE
    case REFERRAL_SUCCESS
    case REFERRALS_ENABLED
    case CONNECT_DIRECT_DEBIT
    case PAYMENT_FAILED
    case OPEN_FOREVER_TAB
    case OPEN_INSURANCE_TAB
    case CROSS_SELL
}
