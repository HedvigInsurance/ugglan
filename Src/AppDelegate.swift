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
import Flow
import Form
import Presentation
import UIKit
import UserNotifications

let log = Logger.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let navigationController = UINavigationController()
    let window = UIWindow(frame: UIScreen.main.bounds)
    var toastWindow: UIWindow?
    private let applicationWillTerminateCallbacker = Callbacker<Void>()
    let applicationWillTerminateSignal: Signal<Void>

    let toastSignal = ReadWriteSignal<Toast?>(nil)

    override init() {
        applicationWillTerminateSignal = applicationWillTerminateCallbacker.signal()
        super.init()
        self.toastWindow = self.createToastWindow()
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
        let token = AuthorizationToken(token: "")
        try? Disk.save(token, to: .applicationSupport, as: "authorization-token.json")

        window.rootViewController = navigationController

        presentMarketing()
    }

    func createToast(
        symbol: ToastSymbol,
        body: String,
        textColor: UIColor = UIColor.offBlack,
        backgroundColor: UIColor = UIColor.white,
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

    func presentMarketing() {
        let marketing = Marketing()

        let marketingPresentation = Presentation(
            marketing,
            style: .marketing,
            options: .defaults
        ).onValue { _ in
            let loggedIn = LoggedIn()
            self.bag += self.window.present(loggedIn, options: [], animated: true)
        }

        bag += navigationController.present(marketingPresentation)
    }

    func presentOnboarding() {
        guard let rootViewController = window.rootViewController else { return }
        bag += rootViewController.present(OnboardingChat(intent: .onboard), options: [.prefersNavigationBarHidden(false)])
    }

    func applicationWillTerminate(_: UIApplication) {
        applicationWillTerminateCallbacker.callAll()
    }

    func application(_: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else { return false }

        if
            let invitedByMemberId = queryItems.filter({ item in item.name == "invitedBy" }).first?.value,
            let incentive = queryItems.filter({ item in item.name == "incentive" }).first?.value {
            Analytics.logEvent("referrals_open", parameters: [
                "invitedByMemberId": invitedByMemberId,
                "incentive": incentive
            ])

            UserDefaults.standard.set(invitedByMemberId, forKey: "referral_invitedByMemberId")
            UserDefaults.standard.set(incentive, forKey: "referral_incentive")

            return true
        }

        guard let referralCode = queryItems.filter({ item in item.name == "code" }).first?.value else { return false }

        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { _, _ in
            guard let rootViewController = self.window.rootViewController else { return }
            let innerBag = self.bag.innerBag()

            innerBag += rootViewController.present(ReferralsReceiverConsent(referralCode: referralCode), style: .modal, options: [
                .prefersNavigationBarHidden(true),
            ]).onValue { result in
                if result == .accept {
                    self.presentOnboarding()
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
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        window.backgroundColor = .offWhite
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

        let hasLoadedCallbacker = Callbacker<Void>()

        let launch = Launch(
            hasLoadedSignal: hasLoadedCallbacker.signal()
        )

        let launchPresentation = Presentation(
            launch,
            style: .modally(
                presentationStyle: .overCurrentContext,
                transitionStyle: .none,
                capturesStatusBarAppearance: true
            ),
            options: [.unanimated, .prefersNavigationBarHidden(true)]
        )

        bag += navigationController.present(launchPresentation)
        window.makeKeyAndVisible()

        let apolloEnvironment = ApolloEnvironmentConfig(
            endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
            wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
            assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
        )

        ApolloContainer.shared.environment = apolloEnvironment

        DefaultStyling.installCustom()

        let token = AuthorizationToken(token: "iRdjaazqSHqtGg==.h/6BEAGKcveJIg==.u2sxTGn+PWkHMg==")
        try? Disk.save(token, to: .applicationSupport, as: "authorization-token.json")

        bag += combineLatest(
            ApolloContainer.shared.initClient().valueSignal.map { _ in true }.plain(),
            RemoteConfigContainer.shared.fetched.plain()
        ).delay(by: 0.5).onValue { _, _ in
            self.presentMarketing()

            hasLoadedCallbacker.callAll()

            TranslationsRepo.fetch()
        }

        return true
    }
}
