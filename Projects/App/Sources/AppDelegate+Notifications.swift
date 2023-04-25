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
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        bag += ApplicationContext.shared.$isLoggedIn.atOnce().filter(predicate: { $0 })
            .onValue { _ in
                let giraffe: hGiraffe = Dependencies.shared.resolve()

                let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })

                giraffe.client
                    .perform(
                        mutation: GiraffeGraphQL.NotificationRegisterDeviceMutation(token: deviceTokenString)
                    )
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
    fileprivate func performPostLoggedIn(work: @escaping () -> Void) {
        bag += ApplicationContext.shared.$isLoggedIn.atOnce().filter { $0 }
            .onFirstValue { _ in
                work()
            }
    }
    
    fileprivate func performPushAction(notificationType: String, userInfo: [AnyHashable: Any]) {
        hAnalyticsEvent.notificationOpened(type: notificationType).send()
        
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
            performPostLoggedIn {
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

        if ChatState.shared.allowNewMessageToast { Toasts.shared.displayToast(toast: toast) }
    }
}
