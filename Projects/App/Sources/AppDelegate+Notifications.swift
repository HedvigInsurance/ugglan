import Apollo
import CoreDependencies
import FirebaseMessaging
import Flow
import Foundation
import Payment
import Presentation
import hCore
import hCoreUI
import hGraphQL

#if PRESENTATION_DEBUGGER
    #if compiler(>=5.5)
        import PresentationDebugSupport
    #endif
#endif

extension AppDelegate: MessagingDelegate {
    func registerFCMToken(_ token: String) {
        bag += ApplicationContext.shared.$hasFinishedBootstrapping.filter(predicate: { $0 })
            .onValue { _ in let client: ApolloClient = Dependencies.shared.resolve()
                client.perform(mutation: GraphQL.RegisterPushTokenMutation(pushToken: token))
                    .onValue { data in
                        if data.registerPushToken != nil {
                            log.info("Did register push token for user")
                        } else {
                            log.info("Failed to register push token for user")
                        }
                    }
            }
    }

    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            ApplicationState.setFirebaseMessagingToken(fcmToken)
            registerFCMToken(fcmToken)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let notificationType = userInfo["TYPE"] as? String else { return }

        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if notificationType == "NEW_MESSAGE" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        let store: UgglanStore = globalPresentableStoreContainer.get()
                        store.send(.openChat)
                    }
            } else if notificationType == "REFERRAL_SUCCESS" || notificationType == "REFERRALS_ENABLED" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        let store: UgglanStore = globalPresentableStoreContainer.get()
                        store.send(.makeTabActive(deeplink: .forever))
                    }
            } else if notificationType == "CONNECT_DIRECT_DEBIT" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        self.window.rootViewController?
                            .present(
                                PaymentSetup(
                                    setupType: .initial,
                                    urlScheme: Bundle.main.urlScheme ?? ""
                                ),
                                style: .modal,
                                options: [.defaults]
                            )
                    }
            } else if notificationType == "PAYMENT_FAILED" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        self.window.rootViewController?
                            .present(
                                PaymentSetup(
                                    setupType: .replacement,
                                    urlScheme: Bundle.main.urlScheme ?? ""
                                ),
                                style: .modal,
                                options: [.defaults]
                            )
                    }
            } else if notificationType == "OPEN_INSURANCE_TAB" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        let store: UgglanStore = globalPresentableStoreContainer.get()
                        store.send(.makeTabActive(deeplink: .insurances))
                    }
            }
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

        if ChatState.shared.allowNewMessageToast { Toasts.shared.displayToast(toast: toast) }
    }
}
