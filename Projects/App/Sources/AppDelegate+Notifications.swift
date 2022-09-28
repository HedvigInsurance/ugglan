import Apollo
import Contracts
import CoreDependencies
import Flow
import Foundation
import Payment
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

extension AppDelegate {
    func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken
                    deviceToken: Data) {
        bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter(predicate: { $0 })
            .onValue { _ in
                let client: ApolloClient = Dependencies.shared.resolve()
                
                let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
                
                client.perform(mutation: GraphQL.NotificationRegisterDeviceMutation(token: deviceTokenString))
                    .onValue { data in
                        if data.notificationRegisterDevice == true {
                            log.info("Did register CustomerIO push token for user")
                        } else {
                            log.info("Failed to register CustomerIO push token for user")
                        }
                    }
            }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.info("Failed to register for remote notifications with error: \(error))")
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

        hAnalyticsEvent.notificationOpened(type: notificationType).send()

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
                                    setupType: .initial
                                )
                                .journeyThenDismiss
                            )
                            .onValue({ _ in

                            })
                    }
            } else if notificationType == "PAYMENT_FAILED" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        self.window.rootViewController?
                            .present(
                                PaymentSetup(
                                    setupType: .replacement
                                )
                                .journeyThenDismiss
                            )
                            .onValue({ _ in

                            })
                    }
            } else if notificationType == "OPEN_FOREVER_TAB" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        let store: UgglanStore = globalPresentableStoreContainer.get()
                        store.send(.makeTabActive(deeplink: .forever))
                    }
            } else if notificationType == "OPEN_INSURANCE_TAB" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        let store: UgglanStore = globalPresentableStoreContainer.get()
                        store.send(.makeTabActive(deeplink: .insurances))
                    }
            } else if notificationType == "CROSS_SELL" {
                bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { _ in
                        let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
                        ugglanStore.send(.makeTabActive(deeplink: .insurances))

                        let contractsStore: ContractStore = globalPresentableStoreContainer.get()

                        guard let crossSellType = userInfo["CROSS_SELL_TYPE"] as? String else { return }

                        self.bag += contractsStore.stateSignal
                            .map { $0.contractBundles.flatMap { contractBundle in contractBundle.crossSells } }
                            .compactMap {
                                $0.first(where: { crossSell in crossSell.notificationType == crossSellType })
                            }
                            .onFirstValue { crossSell in
                                contractsStore.send(.openCrossSellingDetail(crossSell: crossSell))
                            }
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
