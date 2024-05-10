import Apollo
import Chat
import Contracts
import CoreDependencies
import Flow
import Foundation
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
        bag += ApplicationContext.shared.$isLoggedIn.atOnce().filter(predicate: { $0 })
            .onValue { _ in
                let client: NotificationClient = Dependencies.shared.resolve()

                let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
                client.register(for: deviceTokenString)
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
    fileprivate func performPostLoggedIn(work: @escaping () -> Void) {
        bag += ApplicationContext.shared.$isLoggedIn.atOnce().filter { $0 }
            .onFirstValue { _ in
                work()
            }
    }

    fileprivate func performPushAction(notificationType: String, userInfo: [AnyHashable: Any]) {
        if notificationType == "NEW_MESSAGE" {
            performPostLoggedIn {
                let store: UgglanStore = globalPresentableStoreContainer.get()
                store.send(.openChat)
            }
        } else if notificationType == "REFERRAL_SUCCESS" || notificationType == "REFERRALS_ENABLED" {
            performPostLoggedIn {
                let store: UgglanStore = globalPresentableStoreContainer.get()
                store.send(.makeTabActive(deeplink: .forever))
            }
        } else if notificationType == "CONNECT_DIRECT_DEBIT" {
            performPostLoggedIn {
                /* TODO: ADD PUSH NOTIFICATIONS */
            }
        } else if notificationType == "PAYMENT_FAILED" {
            performPostLoggedIn {
                /* TODO: ADD PUSH NOTIFICATIONS */
            }
        } else if notificationType == "OPEN_FOREVER_TAB" {
            performPostLoggedIn {
                let store: UgglanStore = globalPresentableStoreContainer.get()
                store.send(.makeTabActive(deeplink: .forever))
            }
        } else if notificationType == "OPEN_INSURANCE_TAB" {
            performPostLoggedIn {
                let store: UgglanStore = globalPresentableStoreContainer.get()
                store.send(.makeTabActive(deeplink: .insurances))
            }
        } else if notificationType == "CROSS_SELL" {
            performPostLoggedIn {
                let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
                ugglanStore.send(.makeTabActive(deeplink: .insurances))
            }
        }
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let notificationType = userInfo["TYPE"] as? String else { return }

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
        let toast = Toast(
            symbol: .none,
            body: notification.request.content.title,
            subtitle: notification.request.content.body
        )

        self.bag += toast.onTap.onValue {
            let userInfo = notification.request.content.userInfo
            guard let notificationType = userInfo["TYPE"] as? String else { return }

            self.performPushAction(notificationType: notificationType, userInfo: userInfo)
        }

        let store: ChatStore = globalPresentableStoreContainer.get()
        if store.state.allowNewMessageToast { Toasts.shared.displayToast(toast: toast) }
    }
}
