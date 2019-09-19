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
import FirebaseRemoteConfig
import FirebaseMessaging
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
    var toastWindow: UIWindow?
    private let applicationWillTerminateCallbacker = Callbacker<Void>()
    let applicationWillTerminateSignal: Signal<Void>
    let hasFinishedLoading = ReadWriteSignal<Bool>(false)

    let toastSignal = ReadWriteSignal<Toast?>(nil)

    override init() {
        applicationWillTerminateSignal = applicationWillTerminateCallbacker.signal()
        super.init()
        toastWindow = createToastWindow()
    }

    func createToastWindow() -> UIWindow {
        let window = PassTroughWindow(frame: UIScreen.main.bounds)
        window.isOpaque = false
        window.backgroundColor = UIColor.transparent

        let toasts = Toasts(toastSignal: toastSignal)

        bag += window.add(toasts) { toastsView in
            bag += toastSignal.onValue { _ in
                window.makeKeyAndVisible()

                toastsView.snp.remakeConstraints { make in
                    let position: CGFloat = 69
                    if #available(iOS 11.0, *) {
                        let hasModal = self.window.rootViewController?.presentedViewController != nil
                        let safeAreaBottom = self.window.rootViewController?.view.safeAreaInsets.bottom ?? 0
                        let extraPadding: CGFloat = hasModal ? 0 : position
                        make.bottom.equalTo(-(safeAreaBottom + extraPadding))
                    } else {
                        make.bottom.equalTo(-position)
                    }

                    make.centerX.equalToSuperview()
                }
            }
        }

        bag += toasts.idleSignal.onValue { _ in
            self.toastSignal.value = nil
            self.window.makeKeyAndVisible()
        }

        return window
    }

    func logout() {
        bag += ApolloContainer.shared.createClientFromNewSession().onValue { _ in
            self.bag.dispose()
            self.bag += ApplicationState.presentRootViewController(self.window)
        }
    }

    func createToast(
        symbol: ToastSymbol,
        body: String,
        textColor: UIColor = UIColor.primaryText,
        backgroundColor: UIColor = UIColor.secondaryBackground,
        duration: TimeInterval = 5.0
    ) {
        bag += Signal(after: 0).withLatestFrom(toastSignal.atOnce().plain()).onValue(on: .main) { _, previousToast in
            let toast = Toast(
                symbol: symbol,
                body: body,
                textColor: textColor,
                backgroundColor: backgroundColor,
                duration: duration
            )

            if toast != previousToast {
                self.toastSignal.value = toast
            }
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
            guard let queryItems = URLComponents(url: dynamicLinkUrl, resolvingAgainstBaseURL: true)?.queryItems else { return }
            guard let referralCode = queryItems.filter({ item in item.name == "code" }).first?.value else { return }
            
            guard ApplicationState.currentState == nil || ApplicationState.currentState?.isOneOf([.marketing, .onboardingChat, .offer]) == true else { return }
            guard let rootViewController = self.window.rootViewController else { return }
            let innerBag = self.bag.innerBag()
            
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

        return handled
    }

    func registerForPushNotifications() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        UIApplication.shared.registerForRemoteNotifications()
    }

    func application(
        _: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        guard let vc = (window?.rootViewController?.presentedViewController) else {
            return .portrait
        }

        if String(describing: vc).contains("VideoPlayerViewController") {
            return .allButUpsideDown
        }

        return .portrait
    }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let availableLanguages = Localization.Locale.allCases.map { $0.rawValue }

        let bestMatchedLanguage = Bundle.preferredLocalizations(
            from: availableLanguages
        ).first

        if let bestMatchedLanguage = bestMatchedLanguage {
            Localization.Locale.currentLocale = Localization.Locale(rawValue: bestMatchedLanguage) ?? .en_SE
        } else {
            Localization.Locale.currentLocale = .en_SE
        }

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
        
        #if APP_VARIANT_PRODUCTION

        let apolloEnvironment = ApolloEnvironmentConfig(
            endpointURL: URL(string: "https://giraffe.hedvig.com/graphql")!,
            wsEndpointURL: URL(string: "wss://giraffe.hedvig.com/subscriptions")!,
            assetsEndpointURL: URL(string: "https://giraffe.hedvig.com")!
        )
        
        #elseif APP_VARIANT_DEV
        
        let apolloEnvironment = ApolloEnvironmentConfig(
            endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
            wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
            assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
        )
        
        #endif

        ApolloContainer.shared.environment = apolloEnvironment

        DefaultStyling.installCustom()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        bag += combineLatest(
            ApolloContainer.shared.initClient().valueSignal.map { _ in true }.plain(),
            RemoteConfigContainer.shared.fetched.plain()
        ).atValue({ _ in
            TranslationsRepo.fetch()
            self.bag += ApplicationState.presentRootViewController(self.window)
        }).delay(by: 0.1).onValue { _ in
            self.hasFinishedLoading.value = true
        }

        bag += launchFuture.onValue({ _ in
            self.window.makeKeyAndVisible()
            self.launchWindow = nil
        })

        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String) {
        ApolloContainer.shared.client.perform(mutation: RegisterPushTokenMutation(pushToken: fcmToken)).onValue { result in
            if result.data?.registerPushToken != nil {
                log.info("Did register push token for user")
            } else {
                log.info("Failed to register push token for user")
            }
        }
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
            }
        }

        completionHandler()
    }
}
