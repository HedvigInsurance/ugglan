import Adyen
import AdyenActions
import Apollo
import CoreDependencies
import Datadog
import DatadogCrashReporting
import Disk
import Firebase
import FirebaseDynamicLinks
import FirebaseMessaging
import Flow
import Form
import Foundation
import Hero
import Offer
import Payment
import Presentation
import SwiftUI
import UIKit
import UserNotifications
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

#if PRESENTATION_DEBUGGER
    #if compiler(>=5.5)
        import PresentationDebugSupport
    #endif
#endif

let log = Logger.builder
    .sendNetworkInfo(true)
    .printLogsToConsole(true, usingFormat: .shortWith(prefix: "[Hedvig] "))
    .build()

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let window: UIWindow = {
        var window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        return window
    }()

    func logout() {
        ApolloClient.cache = InMemoryNormalizedCache()
        ApolloClient.deleteToken()

        // remove all persisted state
        globalPresentableStoreContainer.deletePersistanceContainer()

        // create new store container to remove all old store instances
        globalPresentableStoreContainer = PresentableStoreContainer()

        setupDebugger()
        setupPresentableStoreLogger()

        bag += ApolloClient.initAndRegisterClient()
            .onValue { _ in ChatState.shared = ChatState()
                self.bag += self.window.present(AppJourney.main)
            }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.post(Notification(name: .applicationWillTerminate))
        hAnalyticsEvent.appShutdown().send()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        hAnalyticsEvent.appBackground().send()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        hAnalyticsEvent.appResumed().send()
    }

    func application(
        _: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let url = userActivity.webpageURL else { return false }

        return DynamicLinks.dynamicLinks()
            .handleUniversalLink(url) { dynamicLink, error in
                if let error = error {
                    log.error("Dynamic Link Error", error: error, attributes: [:])
                }

                guard let dynamicLinkURL = dynamicLink?.url else {
                    return
                }

                self.handleDeepLink(dynamicLinkURL)
            }
    }

    func setToken(_ token: String) {
        ApolloClient.cache = InMemoryNormalizedCache()
        ApolloClient.saveToken(token: token)

        ApolloClient.initAndRegisterClient()
            .always {
                ChatState.shared = ChatState()
                self.bag +=
                    self
                    .window.present(
                        AppJourney.loggedIn
                    )
            }
    }

    func registerForPushNotifications() -> Future<Void> {
        Future { completion in
            UNUserNotificationCenter.current()
                .getNotificationSettings { settings in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if settings.authorizationStatus == .denied {
                        DispatchQueue.main.async { UIApplication.shared.open(settingsUrl) }
                    }
                }

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: authOptions,
                    completionHandler: { _, _ in completion(.success)

                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                )

            return NilDisposer()
        }
    }

    func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        let adyenRedirect = RedirectComponent.applicationDidOpen(from: url)

        if adyenRedirect { return adyenRedirect }

        return false
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: ""
        )
    }

    func setupDebugger() {
        #if PRESENTATION_DEBUGGER
            #if compiler(>=5.5)
                globalPresentableStoreContainer.debugger = PresentableStoreDebugger()
                globalPresentableStoreContainer.debugger?.startServer()
            #endif
        #endif
    }

    func setupPresentableStoreLogger() {
        globalPresentableStoreContainer.logger = { message in
            log.info(message)
        }
    }

    var mixpanelToken: String? { Bundle.main.object(forInfoDictionaryKey: "MixpanelToken") as? String }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if Environment.current == .staging {
            var newArguments = ProcessInfo.processInfo.arguments
            newArguments.append("-FIRDebugEnabled")
            ProcessInfo.processInfo.setValue(newArguments, forKey: "arguments")
        }

        urlSessionClientProvider = {
            return InterceptingURLSessionClient()
        }

        setupPresentableStoreLogger()

        setupAnalyticsAndTracking()

        log.info("Starting app")

        hAnalyticsEvent.identify()
        hAnalyticsEvent.appStarted().send()

        Localization.Locale.currentLocale = ApplicationState.preferredLocale

        bag += Localization.Locale.$currentLocale.distinct()
            .onValue { locale in ApplicationState.setPreferredLocale(locale)
                ApolloClient.acceptLanguageHeader = locale.acceptLanguageHeader

                ApolloClient.initAndRegisterClient()
                    .always {
                        ChatState.shared = ChatState()
                        let client: ApolloClient = Dependencies.shared.resolve()
                        self.bag +=
                            client.perform(
                                mutation: GraphQL.UpdateLanguageMutation(
                                    language: locale.code,
                                    pickedLocale: locale.asGraphQLLocale()
                                )
                            )
                            .sink()
                    }
            }

        ApolloClient.bundle = Bundle.main
        ApolloClient.acceptLanguageHeader = Localization.Locale.currentLocale.acceptLanguageHeader

        AskForRating().registerSession()
        CrossFrameworkCoordinator.setup()

        FirebaseApp.configure()
        let launch = Launch()

        let (launchView, launchFuture) = launch.materialize()
        window.rootView.addSubview(launchView)
        launchView.layer.zPosition = .greatestFiniteMagnitude - 2

        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()

        launchView.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

        DefaultStyling.installCustom()

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // treat an empty token as a newly downloaded app and setLastNewsSeen
        if ApolloClient.retreiveToken() == nil { ApplicationState.setLastNewsSeen() }

        setupDebugger()

        bag += ApolloClient.initAndRegisterClient().valueSignal.map { _ in true }.plain()
            .atValue { _ in
                Dependencies.shared.add(module: Module { AnalyticsCoordinator() })

                AnalyticsCoordinator().setUserId()

                self.bag += self.window.present(AppJourney.main)

                launch.completeAnimationCallbacker.callAll()
            }

        bag += launchFuture.onValue { _ in launchView.removeFromSuperview()
            ApplicationContext.shared.hasFinishedBootstrapping = true

            if Environment.hasOverridenDefault {
                let toast = Toast(
                    symbol: .icon(hCoreUIAssets.settingsIcon.image),
                    body: "Targeting \(Environment.current.displayName) environment",
                    textColor: .black,
                    backgroundColor: .brand(.regularCaution)
                )

                if #available(iOS 13, *) {
                    self.bag += toast.onTap.onValue {
                        self.window.rootViewController?
                            .present(
                                UIHostingController(rootView: Debug()),
                                style: .detented(.medium, .large),
                                options: []
                            )
                    }
                }

                Toasts.shared.displayToast(toast: toast)
            }
        }

        return true
    }
}

extension ApolloClient {
    public static func initAndRegisterClient() -> Future<Void> {
        Self.initClient()
            .onValue { store, client in
                Dependencies.shared.add(module: Module { store })
                Dependencies.shared.add(module: Module { client })
            }
            .toVoid()
    }
}
