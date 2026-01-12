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

extension AppDelegate {
    func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            let client: NotificationClient = Dependencies.shared.resolve()
            let deviceTokenString = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
            try await client.register(for: deviceTokenString)
        }
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
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
    fileprivate func performPushAction(notificationType: PushNotificationType?, userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: .handlePushNotification,
            object: notificationType,
            userInfo: userInfo
        )
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let notificationType = getNotificationType(from: userInfo) else { return }

        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            Task {
                performPushAction(notificationType: notificationType, userInfo: userInfo)
            }
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        completionHandler()
    }

    private func getNotificationType(from userInfo: [AnyHashable: Any]) -> PushNotificationType? {
        if let type = (userInfo["TYPE"] as? String) ?? (userInfo["type"] as? String) {
            return PushNotificationType(rawValue: type.uppercased())
        }
        return nil
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let shouldShowNotification: Bool = {
            guard let notificationType = getNotificationType(from: notification.request.content.userInfo) else {
                return true
            }
            guard let topPresentedVCDescription = UIApplication.shared.getTopVisibleVc()?.debugDescription else {
                return true
            }

            if notificationType != .NEW_MESSAGE { return true }
            let listToCheck: [String] = [
                String(describing: HomeScreen.self),
                .init(describing: ClaimDetailView.self),
                .init(describing: InboxView.self),
                .init(describing: ChatScreen.self),
            ]
            let shouldShow = !listToCheck.contains(where: { $0 == topPresentedVCDescription })
            return shouldShow
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
    case ADDON_TRAVEL
    case CLAIM_CLOSED
    case OPEN_CLAIM
    case INSURANCE_EVIDENCE
    case TRAVEL_CERTIFICATE
}
