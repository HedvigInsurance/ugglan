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

struct AppNotification {
    let body: String
}

extension AppNotification : Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 8
        view.layer.shadowColor = UIColor.darkGray.cgColor
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
    
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        let text = MultilineLabel(value: body, style: .bodyOffBlack)
        
        bag += stackView.addArranged(text)
        
        return (view, bag)
    }
}

struct AppNotifications {
    let notificationSignal: ReadWriteSignal<String>
}

extension AppNotifications : Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIView()
        
        let stackView = UIStackView()
        stackView.edgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        bag += notificationSignal.onValue { data in
            let appNotification = AppNotification(body: data)

            bag += stackView.addArranged(appNotification) { appNotificationView in
                appNotificationView.layer.opacity = 0
                appNotificationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                
                appNotificationView.snp.makeConstraints { make in
                    make.width.equalToSuperview().inset(16)
                    make.height.equalTo(66)
                }
                
                bag += Signal(after: 0).feedback(type: .impactMedium)
                
                bag += Signal(after: 0).animated(style: SpringAnimationStyle.heavyBounce()) { _ in
                    appNotificationView.layer.opacity = 1
                    appNotificationView.transform = CGAffineTransform.identity
                }
                
                bag += Signal(after: 4).animated(style: AnimationStyle.easeOut(duration: 0.5)) { _ in
                    appNotificationView.layer.opacity = 0
                    appNotificationView.transform = CGAffineTransform(translationX: -100, y: 0)
                }.animated(style: AnimationStyle.easeOut(duration: 0.3)) { _ in
                    appNotificationView.isHidden = true
                }.onValue { _ in
                    stackView.removeArrangedSubview(appNotificationView)
                }
            }
        }
        
        bag += stackView.makeConstraints(wasAdded: events.wasAdded).onValue { make, safeArea in
            make.width.height.equalToSuperview()
        }
        
        return (view, bag)
    }
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let navigationController = UINavigationController()
    let window = UIWindow(frame: UIScreen.main.bounds)
    private let applicationWillTerminateCallbacker = Callbacker<Void>()
    let applicationWillTerminateSignal: Signal<Void>
    
    let notificationSignal = ReadWriteSignal<String>("")

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
            
            let appNotifications = AppNotifications(notificationSignal: self.notificationSignal)
        
            self.bag += self.window.rootViewController!.view.add(appNotifications) { appNotificationsView in
                appNotificationsView.snp.makeConstraints { make in
                    if #available(iOS 11.0, *) {
                        make.top.equalTo(self.window.rootViewController!.view.safeAreaInsets.top)
                    }
                    
                    make.width.equalTo(UIScreen.main.bounds.width)
                }
            }
            
            self.bag += Signal(after: 1).onValue { _  in
                self.notificationSignal.value = "Notific 1"
            }
            
            self.bag += Signal(after: 3).onValue { _  in
                self.notificationSignal.value = "Notis 2"
            }
            
            self.bag += Signal(after: 5).onValue { _  in
                self.notificationSignal.value = "Notis 3"
            }
            
            self.bag += Signal(after: 7).onValue { _  in
                self.notificationSignal.value = "Notis 4"
            }
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
