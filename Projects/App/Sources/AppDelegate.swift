//
//  AppDelegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Adyen
import Apollo
import Disk
import Firebase
import FirebaseMessaging
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Mixpanel
import Presentation
import Sentry
import UIKit
import UserNotifications

let log = Logger.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let navigationController = UINavigationController()
    let window = UIWindow(frame: UIScreen.main.bounds)
    var launchWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    private let applicationWillTerminateCallbacker = Callbacker<Void>()
    let applicationWillTerminateSignal: Signal<Void>
    let hasFinishedLoading = ReadWriteSignal<Bool>(false)

    let toastSignal = ReadWriteSignal<Toast?>(nil)

    override init() {
        applicationWillTerminateSignal = applicationWillTerminateCallbacker.signal()
        super.init()
    }

    func presentToasts() {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }

        let toastBag = bag.innerBag()
        let toasts = Toasts(toastSignal: toastSignal)

        toastBag += keyWindow.add(toasts) { toastsView in toastBag += toastSignal.atOnce().onValue { _ in
            toastsView.snp.remakeConstraints { make in
                if #available(iOS 13, *), keyWindow.traitCollection.userInterfaceIdiom != .pad {
                    if keyWindow.rootViewController?.presentedViewController != nil {
                        let safeAreaTop = keyWindow.safeAreaInsets.top
                        make.top.equalTo(safeAreaTop == 0 ? 10 : safeAreaTop + 20)
                    } else {
                        let safeAreaTop = keyWindow.safeAreaInsets.top
                        make.top.equalTo(safeAreaTop == 0 ? 10 : safeAreaTop)
                    }
                } else {
                    let safeAreaTop = keyWindow.safeAreaInsets.top
                    make.top.equalTo(safeAreaTop == 0 ? 10 : safeAreaTop)
                }

                make.centerX.equalToSuperview()
            }
        }
        }

        toastBag += toasts.idleSignal.onValue { _ in
            self.toastSignal.value = nil
            toastBag.dispose()
        }
    }

    func logout() {
        ApolloClient.cache = InMemoryNormalizedCache()
        bag += ApolloClient.createClientFromNewSession().onValue { _ in
            self.bag.dispose()
            self.bag += ApplicationState.presentRootViewController(self.window)
        }
    }

    func displayToast(
        _ toast: Toast
    ) -> Future<Void> {
        return Future { completion in
            self.bag += Signal(after: 0).withLatestFrom(self.toastSignal.atOnce().plain()).onValue(on: .main) { _, previousToast in
                if self.toastSignal.value == nil {
                    self.presentToasts()
                }

                if toast != previousToast {
                    self.toastSignal.value = toast
                }

                self.bag += self.toastSignal.take(first: 1).onValue { _ in
                    completion(.success)
                }
            }

            return NilDisposer()
        }
    }

    func applicationWillTerminate(_: UIApplication) {
        applicationWillTerminateCallbacker.callAll()
    }

    func application(_: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else { return false }
        guard let dynamicLink = queryItems.first(where: { $0.name == "link" }) else { return false }
        guard let dynamicLinkUrl = URL(string: dynamicLink.value) else { return false }

        return handleDeepLink(dynamicLinkUrl)
    }

    func registerForPushNotifications() -> Future<Void> {
        return Future { completion in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if settings.authorizationStatus == .denied {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in
                    completion(.success)

                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            )

            return NilDisposer()
        }
    }

    func handleDeepLink(_ dynamicLinkUrl: URL) -> Bool {
        if dynamicLinkUrl.pathComponents.contains("direct-debit") {
            guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return false }
            guard let rootViewController = window.rootViewController else { return false }

            Mixpanel.mainInstance().track(event: "DEEP_LINK_DIRECT_DEBIT")

            bag += rootViewController.present(
                PaymentSetup(setupType: .initial),
                style: .modal,
                options: [.defaults]
            )

            return true
        } else if dynamicLinkUrl.pathComponents.contains("forever") {
            guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return false }
            bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                NotificationCenter.default.post(Notification(name: .shouldOpenReferrals))
            }

            Mixpanel.mainInstance().track(event: "DEEP_LINK_FOREVER")

            return true
        }

        guard let queryItems = URLComponents(url: dynamicLinkUrl, resolvingAgainstBaseURL: true)?.queryItems else { return false }
        guard let referralCode = queryItems.filter({ item in item.name == "code" }).first?.value else { return false }

        guard ApplicationState.currentState == nil || ApplicationState.currentState?.isOneOf([.marketing, .marketPicker, .onboardingChat, .offer]) == true else { return false }
        guard let rootViewController = window.rootViewController else { return false }
        let innerBag = bag.innerBag()

        func presentReferralsAccept() {
            innerBag += rootViewController.present(
                ReferralsReceiverConsent(referralCode: referralCode),
                style: .modal,
                options: [
                    .prefersNavigationBarHidden(true),
                    .allowSwipeDismissAlways,
                ]
            ).onValue { result in
                if result == .accept {
                    if ApplicationState.currentState?.isOneOf([.marketing]) == true {
                        self.bag += rootViewController.present(
                            Onboarding(),
                            options: [.prefersNavigationBarHidden(false)]
                        )
                    }
                }
                innerBag.dispose()
            }
        }

        if ApplicationState.hasPreferredLocale {
            presentReferralsAccept()
        } else {
            bag += rootViewController.present(MarketPicker {
                presentReferralsAccept()
            })
        }

        Mixpanel.mainInstance().track(event: "DEEP_LINK_REFERRALS")

        return true
    }

    func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        let adyenRedirect = RedirectComponent.applicationDidOpen(from: url)

        if adyenRedirect {
            return adyenRedirect
        }

        return false
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "")
    }

    var mixpanelToken: String? {
        return Bundle.main.object(forInfoDictionaryKey: "MixpanelToken") as? String
    }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        SentrySDK.start { options in
            options.dsn = "https://09505787f04f4c6ea7e560de075ba552@o123400.ingest.sentry.io/5208267"
            #if DEBUG
                options.debug = true
            #endif
            options.environment = ApplicationState.getTargetEnvironment().displayName
            options.enableAutoSessionTracking = true
        }

        if let mixpanelToken = mixpanelToken {
            Mixpanel.initialize(token: mixpanelToken)
        }

        AskForRating().registerSession()

        Button.trackingHandler = { button in
            if let localizationKey = button.title.value.derivedFromL10n?.key {
                Mixpanel.mainInstance().track(event: localizationKey, properties: [
                    "context": "Button",
                ])
            }
        }

        Localization.Locale.currentLocale = ApplicationState.preferredLocale
        Bundle.setLanguage(Localization.Locale.currentLocale.lprojCode)
        FirebaseApp.configure()

        launchWindow?.isOpaque = false
        launchWindow?.backgroundColor = UIColor.transparent

        window.rootViewController = navigationController

        presentablePresentationEventHandler = { (event: () -> PresentationEvent, file, function, line) in
            let presentationEvent = event()
            let message: String
            var data: String?

            switch presentationEvent {
            case let .willEnqueue(presentableId, context):
                Mixpanel.mainInstance().track(event: "PRESENTABLE_WILL_ENQUEUE", properties: [
                    "presentableId": presentableId.value,
                ])
                message = "\(context) will enqueue modal presentation of \(presentableId)"
            case let .willDequeue(presentableId, context):
                Mixpanel.mainInstance().track(event: "PRESENTABLE_WILL_DEQUEUE", properties: [
                    "presentableId": presentableId.value,
                ])
                message = "\(context) will dequeue modal presentation of \(presentableId)"
            case let .willPresent(presentableId, context, styleName):
                Mixpanel.mainInstance().track(event: "PRESENTABLE_WILL_PRESENT", properties: [
                    "presentableId": presentableId.value,
                ])

                SentrySDK.configureScope { scope in
                    scope.setExtra(value: presentableId.value, key: "presentableId")
                }

                message = "\(context) will '\(styleName)' present: \(presentableId)"
            case let .didCancel(presentableId, context):
                Mixpanel.mainInstance().track(event: "PRESENTABLE_DID_CANCEL", properties: [
                    "presentableId": presentableId.value,
                ])
                message = "\(context) did cancel presentation of: \(presentableId)"
            case let .didDismiss(presentableId, context, result):
                switch result {
                case let .success(result):
                    Mixpanel.mainInstance().track(event: "PRESENTABLE_DID_DISMISS_SUCCESS", properties: [
                        "presentableId": presentableId.value,
                    ])
                    message = "\(context) did end presentation of: \(presentableId)"
                    data = "\(result)"
                case let .failure(error):
                    Mixpanel.mainInstance().track(event: "PRESENTABLE_DID_DISMISS_FAILURE", properties: [
                        "presentableId": presentableId.value,
                    ])
                    message = "\(context) did end presentation of: \(presentableId)"
                    data = "\(error)"
                }
            }

            presentableLogPresentation(message, data, file, function, line)
        }

        viewControllerWasPresented = { viewController in
            if let debugPresentationTitle = viewController.debugPresentationTitle {
                Mixpanel.mainInstance().track(event: "SCREEN_VIEW_\(debugPresentationTitle)")
            }
        }
        alertActionWasPressed = { _, title in
            if let localizationKey = title.derivedFromL10n?.key {
                Mixpanel.mainInstance().track(event:
                    "ALERT_ACTION_TAP_\(localizationKey)"
                )
            }
        }
        RowAndProviderTracking.handler = { event in
            Mixpanel.mainInstance().track(event: event)
        }

        let launch = Launch(
            hasLoadedSignal: hasFinishedLoading.toVoid().plain()
        )

        let (launchViewController, launchFuture) = launch.materialize()
        launchWindow?.rootViewController = launchViewController
        window.makeKeyAndVisible()
        launchWindow?.makeKeyAndVisible()

        DefaultStyling.installCustom()

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        bag += ApolloClient.initClient().valueSignal.map { _ in true }.plain().atValue { _ in
            Dependencies.shared.add(module: Module { () -> AnalyticsCoordinator in
                AnalyticsCoordinator()
            })

            AnalyticsCoordinator().setUserId()

            self.bag += ApplicationState.presentRootViewController(self.window)

            if ApplicationState.hasOverridenTargetEnvironment {
                self.displayToast(Toast(
                    symbol: .character("🧙‍♂️"),
                    body: "You are using the \(ApplicationState.getTargetEnvironment().displayName) environment."
                )
                ).onValue { _ in }
            }
        }.delay(by: 0.1).onValue { _ in
            let client: ApolloClient = Dependencies.shared.resolve()
            self.bag += client.fetch(query: FeaturesQuery()).onValue { _ in
                self.hasFinishedLoading.value = true
            }
        }

        bag += launchFuture.onValue { _ in
            self.window.makeKeyAndVisible()
            self.launchWindow = nil
        }

        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func registerFCMToken(_ token: String) {
        let client: ApolloClient = Dependencies.shared.resolve()
        client.perform(mutation: RegisterPushTokenMutation(pushToken: token)).onValue { result in
            if result.data?.registerPushToken != nil {
                log.info("Did register push token for user")
            } else {
                log.info("Failed to register push token for user")
            }
        }
    }

    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String) {
        ApplicationState.setFirebaseMessagingToken(fcmToken)
        registerFCMToken(fcmToken)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let notificationType = userInfo["TYPE"] as? String else { return }

        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if notificationType == "NEW_MESSAGE" {
                if ApplicationState.currentState == .onboardingChat {
                    return
                } else if ApplicationState.currentState == .offer {
                    bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                        self.window.rootViewController?.present(
                            OfferChat(),
                            style: .modally(
                                presentationStyle: .pageSheet,
                                transitionStyle: nil,
                                capturesStatusBarAppearance: true
                            )
                        )
                    }
                    return
                } else if ApplicationState.currentState == .loggedIn {
                    bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                        self.window.rootViewController?.present(
                            FreeTextChat(),
                            style: .modally(
                                presentationStyle: .pageSheet,
                                transitionStyle: nil,
                                capturesStatusBarAppearance: true
                            )
                        )
                    }
                    return
                }
            } else if notificationType == "REFERRAL_SUCCESS" || notificationType == "REFERRALS_ENABLED" {
                bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                    NotificationCenter.default.post(Notification(name: .shouldOpenReferrals))
                }
            } else if notificationType == "CONNECT_DIRECT_DEBIT" {
                bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                    self.window.rootViewController?.present(
                        PaymentSetup(setupType: .initial),
                        style: .modal,
                        options: [.defaults]
                    )
                }
            } else if notificationType == "PAYMENT_FAILED" {
                bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                    self.window.rootViewController?.present(
                        PaymentSetup(setupType: .replacement),
                        style: .modal,
                        options: [.defaults]
                    )
                }
            }
        }

        completionHandler()
    }
}
