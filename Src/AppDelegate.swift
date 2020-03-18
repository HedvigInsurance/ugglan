//
//  AppDelegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Disk
import Firebase
import FirebaseAnalytics
import FirebaseMessaging
import FirebaseRemoteConfig
import Flow
import Form
import Foundation
import Presentation
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

        toastBag += keyWindow.add(toasts) { toastsView in
            toastBag += toastSignal.atOnce().onValue { _ in
                toastsView.snp.remakeConstraints { make in
                    if #available(iOS 13, *), !keyWindow.traitCollection.isPad {
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

        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { link, _ in
            guard let dynamicLinkUrl = link?.url else { return }
            self.handleDeepLink(dynamicLinkUrl)
        }

        return handled
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

    func handleDeepLink(_ dynamicLinkUrl: URL) {
        if dynamicLinkUrl.pathComponents.contains("direct-debit") {
            guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return }
            guard let rootViewController = window.rootViewController else { return }

            bag += rootViewController.present(
                DirectDebitSetup(setupType: .initial),
                style: .modal,
                options: [.defaults]
            )

            return
        }

        guard let queryItems = URLComponents(url: dynamicLinkUrl, resolvingAgainstBaseURL: true)?.queryItems else { return }
        guard let referralCode = queryItems.filter({ item in item.name == "code" }).first?.value else { return }

        guard ApplicationState.currentState == nil || ApplicationState.currentState?.isOneOf([.marketing, .onboardingChat, .offer]) == true else { return }
        guard let rootViewController = window.rootViewController else { return }
        let innerBag = bag.innerBag()

        innerBag += rootViewController.present(
            ReferralsReceiverConsent(referralCode: referralCode),
            style: .modal,
            options: [
                .prefersNavigationBarHidden(true),
            ]
        ).onValue { result in
            if result == .accept {
                if ApplicationState.currentState?.isOneOf([.marketing]) == true {
                    self.bag += rootViewController.present(
                        OnboardingChat(),
                        options: [.prefersNavigationBarHidden(false)]
                    )
                }
            }
            innerBag.dispose()
        }
    }

    func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            guard let dynamicLinkUrl = dynamicLink.url else { return false }
            handleDeepLink(dynamicLinkUrl)
            return true
        }
        return false
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "")
    }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Localization.Locale.currentLocale = ApplicationState.preferredLocale

        FirebaseApp.configure()

        launchWindow?.isOpaque = false
        launchWindow?.backgroundColor = UIColor.transparent

        window.rootViewController = navigationController
        viewControllerWasPresented = { viewController in
            let mirror = Mirror(reflecting: viewController)
            Analytics.setScreenName(
                viewController.debugPresentationTitle,
                screenClass: String(describing: mirror.subjectType)
            )
        }
        alertActionWasPressed = { _, title in
            if let localizationKey = title.localizationKey?.description {
                Analytics.logEvent(
                    "alert_action_tap_\(localizationKey)",
                    parameters: nil
                )
            }
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

        let remoteConfigContainer = RemoteConfigContainer()

        Dependencies.shared.add(module: Module { () -> RemoteConfigContainer in
            remoteConfigContainer
        })
        
        bag += combineLatest(
            ApolloClient.initClient().valueSignal.map { _ in true }.plain(),
            remoteConfigContainer.fetched.take(first: 1).plain(),
            TranslationsRepo.fetch().valueSignal.plain()
        ).atValue { _ in
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
            } else if notificationType == "REFERRAL_SUCCESS" {
                guard let incentiveString = userInfo["DATA_MESSAGE_REFERRED_SUCCESS_INCENTIVE_AMOUNT"] as? String else { return }
                guard let name = userInfo["DATA_MESSAGE_REFERRED_SUCCESS_NAME"] as? String else { return }

                let incentive = Int(Double(incentiveString) ?? 0)

                let referralsNotification = ReferralsNotification(
                    incentive: incentive,
                    name: name
                )

                bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                    self.window.rootViewController?.present(
                        referralsNotification,
                        style: .modal,
                        options: [.prefersNavigationBarHidden(false)]
                    )
                }
            } else if notificationType == "CONNECT_DIRECT_DEBIT" {
                bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                    self.window.rootViewController?.present(
                        DirectDebitSetup(),
                        style: .modal,
                        options: [.defaults]
                    )
                }
            } else if notificationType == "PAYMENT_FAILED" {
                bag += hasFinishedLoading.atOnce().filter { $0 }.onValue { _ in
                    self.window.rootViewController?.present(
                        DirectDebitSetup(),
                        style: .modal,
                        options: [.defaults]
                    )
                }
            }
        }

        completionHandler()
    }
}
