import Adyen
import Apollo
import CoreDependencies
import Datadog
import DatadogCrashReporting
import Disk
import Firebase
import FirebaseMessaging
import Flow
import Form
import Foundation
import Hero
import Mixpanel
import Offer
import Payment
import Presentation
import Shake
import SwiftUI
import UIKit
import UserNotifications
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
        UgglanStore.destroy()
        OfferStore.destroy()

        // create new store container to remove all old store instances
        globalPresentableStoreContainer = PresentableStoreContainer()

        setupDebugger()
        setupPresentableStoreLogger()

        bag += ApolloClient.initAndRegisterClient()
            .onValue { _ in ChatState.shared = ChatState()
                self.bag += self.window.present(AppJourney.main)
            }
    }

    func applicationWillTerminate(_: UIApplication) {
        NotificationCenter.default.post(Notification(name: .applicationWillTerminate))
    }

    func application(
        _: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
            return false
        }
        guard let dynamicLink = queryItems.first(where: { $0.name == "link" }) else { return false }
        guard let dynamicLinkUrl = URL(string: dynamicLink.value) else { return false }

        return handleDeepLink(dynamicLinkUrl)
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

    func handleDeepLink(_ dynamicLinkUrl: URL) -> Bool {
        if dynamicLinkUrl.pathComponents.contains("direct-debit") {
            guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return false }
            guard let rootViewController = window.rootViewController else { return false }

            Mixpanel.mainInstance().track(event: "DEEP_LINK_DIRECT_DEBIT")

            bag += rootViewController.present(
                PaymentSetup(setupType: .initial, urlScheme: Bundle.main.urlScheme ?? ""),
                style: .modal,
                options: [.defaults]
            )

            return true
        } else if dynamicLinkUrl.pathComponents.contains("forever") {
            guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return false }
            bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { _ in
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    store.send(.makeForeverTabActive)
                }

            Mixpanel.mainInstance().track(event: "DEEP_LINK_FOREVER")

            return true
        }

        return false
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
        setupPresentableStoreLogger()

        Datadog.initialize(
            appContext: .init(),
            trackingConsent: .granted,
            configuration: Datadog.Configuration
                .builderUsing(
                    rumApplicationID: "416e8fc0-c96a-4485-8c74-84412960a479",
                    clientToken: "pub4306832bdc5f2b8b980c492ec2c11ef3",
                    environment: Environment.current.datadogName
                )
                .set(serviceName: "ios")
                .set(endpoint: .eu1)
                .enableLogging(true)
                .enableTracing(true)
                .enableCrashReporting(using: DDCrashReportingPlugin())
                .build()
        )

        Global.rum = RUMMonitor.initialize()
        Global.sharedTracer = Tracer.initialize(
            configuration: .init(
                serviceName: "ios",
                sendNetworkInfo: true,
                bundleWithRUM: true,
                globalTags: [:]
            )
        )
        
        NetworkInterceptorProvider.tracingInterceptor = TracingInterceptor()

        log.info("Starting app")

        if hGraphQL.Environment.current == .staging || hGraphQL.Environment.hasOverridenDefault {
            Shake.setup()
            Datadog.verbosityLevel = .debug
        }

        if let mixpanelToken = mixpanelToken {
            Mixpanel.initialize(token: mixpanelToken)
            AnalyticsSender.sendEvent = { event, properties in
                log.info("Sending analytics event: \(event)")
                
                Mixpanel.mainInstance()
                    .track(
                        event: event,
                        properties: properties.mapValues({ property in
                            property.mixpanelType
                        })
                    )
            }
        }

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
                            .onValue { _ in }
                    }
            }

        ApolloClient.bundle = Bundle.main
        ApolloClient.acceptLanguageHeader = Localization.Locale.currentLocale.acceptLanguageHeader

        AskForRating().registerSession()
        CrossFrameworkCoordinator.setup()

        FirebaseApp.configure()
        
        presentablePresentationEventHandler = { (event: () -> PresentationEvent, file, function, line) in
            let presentationEvent = event()
            let message: String
            var data: String?

            switch presentationEvent {
            case let .willEnqueue(presentableId, context):
                Mixpanel.mainInstance()
                    .track(
                        event: "PRESENTABLE_WILL_ENQUEUE",
                        properties: ["presentableId": presentableId.value]
                    )
                message = "\(context) will enqueue modal presentation of \(presentableId)"
                log.info(message)
            case let .willDequeue(presentableId, context):
                Mixpanel.mainInstance()
                    .track(
                        event: "PRESENTABLE_WILL_DEQUEUE",
                        properties: ["presentableId": presentableId.value]
                    )
                message = "\(context) will dequeue modal presentation of \(presentableId)"
                log.info(message)
            case let .willPresent(presentableId, context, styleName):
                Mixpanel.mainInstance()
                    .track(
                        event: "PRESENTABLE_WILL_PRESENT",
                        properties: ["presentableId": presentableId.value]
                    )
                Global.rum.startView(key: presentableId.value)
                message = "\(context) will '\(styleName)' present: \(presentableId)"
                log.info(message)
            case let .didCancel(presentableId, context):
                Mixpanel.mainInstance()
                    .track(
                        event: "PRESENTABLE_DID_CANCEL",
                        properties: ["presentableId": presentableId.value]
                    )
                Global.rum.stopView(key: presentableId.value)
                Global.rum.startView(key: context.value)
                message = "\(context) did cancel presentation of: \(presentableId)"
                log.info(message)
            case let .didDismiss(presentableId, context, result):
                switch result {
                case let .success(result):
                    Mixpanel.mainInstance()
                        .track(
                            event: "PRESENTABLE_DID_DISMISS_SUCCESS",
                            properties: ["presentableId": presentableId.value]
                        )
                    message = "\(context) did end presentation of: \(presentableId)"
                    data = "\(result)"
                case let .failure(error):
                    Mixpanel.mainInstance()
                        .track(
                            event: "PRESENTABLE_DID_DISMISS_FAILURE",
                            properties: ["presentableId": presentableId.value]
                        )
                    message = "\(context) did end presentation of: \(presentableId)"
                    data = "\(error)"
                }
                Global.rum.stopView(key: presentableId.value)
                Global.rum.startView(key: context.value)
                log.info(message)
            #if DEBUG
                case let .didDeallocate(presentableId, from: context):
                    message = "\(presentableId) was deallocated after presentation from \(context)"
                    log.info(message)
                case let .didLeak(presentableId, from: context):
                    message =
                        "WARNING \(presentableId) was NOT deallocated after presentation from \(context)"
                    log.info(message)
            #endif
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
                Mixpanel.mainInstance().track(event: "ALERT_ACTION_TAP_\(localizationKey)")
            }
        }
        RowAndProviderTracking.handler = { event in Mixpanel.mainInstance().track(event: event) }
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
                        store.send(.makeForeverTabActive)
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
            }
        }

        completionHandler()
    }
}
