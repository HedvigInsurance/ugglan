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

let log = Logger.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let navigationController = UINavigationController()
    let window = UIWindow(frame: UIScreen.main.bounds)
    private let applicationWillTerminateCallbacker = Callbacker<Void>()
    let applicationWillTerminateSignal: Signal<Void>

    override init() {
        applicationWillTerminateSignal = applicationWillTerminateCallbacker.signal()
        super.init()
    }

    func logout() {
        let token = AuthorizationToken(token: "")
        try? Disk.save(token, to: .applicationSupport, as: "authorization-token.json")

        window.rootViewController = navigationController

        presentMarketing()
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

            if viewController.debugPresentationTitle == "LoggedIn" {
                Analytics.setUserProperty("true", forName: "isMember")
            }
        }
        alertActionWasPressed = { _, title in
            if let localizationKey = title.localizationKey?.toString() {
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
