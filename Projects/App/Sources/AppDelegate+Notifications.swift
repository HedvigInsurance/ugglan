import Apollo
import Chat
import Claims
import Contracts
import CoreDependencies
import Foundation
import Home
import Payment
import PresentableStore
import Profile
import SwiftUI
@preconcurrency import UserNotifications
import hCore
import hCoreUI
import hGraphQL

extension AppDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            let client: NotificationClient = Dependencies.shared.resolve()
            let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
            try await client.register(for: deviceTokenString)
        }
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
                        let status = settings.authorizationStatus.rawValue
                        Task {
                            let store: ProfileStore = await globalPresentableStoreContainer.get()
                            store.send(.setPushNotificationStatus(status: status))
                        }
                    }
            }
        )
        Task {
            let status = await UNUserNotificationCenter.current().notificationSettings()
            let store: ProfileStore = globalPresentableStoreContainer.get()
            store.send(.setPushNotificationStatus(status: status.authorizationStatus.rawValue))
        }
    }
}

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    @MainActor
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
            Task {
                performPushAction(notificationType: notificationType, userInfo: userInfo)
            }
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let shouldShowNotification: Bool = {
            if let topPresentedVCDescription = UIApplication.shared.getTopVisibleVc()?.debugDescription {
                let listToCheck: [String] = [
                    String(describing: HomeScreen.self).components(separatedBy: "<").first ?? "",
                    .init(describing: ClaimDetailView.self),
                    .init(describing: InboxView.self),
                    .init(describing: ChatScreen.self),
                ]
                let shouldShow = !listToCheck.contains(where: { $0 == topPresentedVCDescription })
                return shouldShow
            }
            return true
        }()

        return shouldShowNotification ? [.badge, .banner, .sound] : []
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
    case OPEN_CONTACT_INFO
    case CHANGE_TIER
}
