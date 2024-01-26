import Apollo
import Authentication
import Chat
import Claims
import CoreDependencies
import Datadog
import DatadogCrashReporting
import Disk
import Flow
import Form
import Foundation
import Hero
import Payment
import Presentation
import Profile
import SwiftUI
import TravelCertificate
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

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let deepLinkDisposeBag = DisposeBag()
    let featureFlagsBag = DisposeBag()
    let window: UIWindow = {
        var window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        return window
    }()

    func presentMainJourney() {
        ApolloClient.cache = InMemoryNormalizedCache()

        // remove all persisted state
        globalPresentableStoreContainer.deletePersistanceContainer()

        // create new store container to remove all old store instances
        globalPresentableStoreContainer = PresentableStoreContainer()

        self.setupSession()

        self.bag += ApolloClient.initAndRegisterClient()
            .onValue { _ in
                self.bag += self.window.present(AppJourney.main)
                UIView.transition(
                    with: self.window,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: {},
                    completion: { _ in }
                )
            }
    }

    func logout() {
        bag.dispose()

        let authenticationStore: AuthenticationStore = globalPresentableStoreContainer.get()
        authenticationStore.send(.logout)
        ApplicationContext.shared.$isLoggedIn.value = false
        ApolloClient.deleteToken()
        self.presentMainJourney()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.post(Notification(name: .applicationWillTerminate))
        Thread.sleep(forTimeInterval: 3)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UserDefaults(suiteName: "group.\(Bundle.main.bundleIdentifier!)")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(
        _: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        if let rootVC = window.rootViewController {
            self.handleDeepLink(url, fromVC: rootVC)
        }
        return true
    }

    func registerForPushNotifications() -> Future<Void> {
        Future { completion in
            UNUserNotificationCenter.current()
                .getNotificationSettings { settings in
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
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
                    completionHandler: { _, _ in

                        UNUserNotificationCenter.current()
                            .getNotificationSettings { settings in
                                let store: ProfileStore = globalPresentableStoreContainer.get()
                                store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
                            }
                        completion(.success)
                    }
                )

            return NilDisposer()
        }
    }

    func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        if url.relativePath.contains("login-failure") {
            let authenticationStore: AuthenticationStore = globalPresentableStoreContainer.get()
            authenticationStore.send(.loginFailure(message: nil))
        }

        let impersonate = Impersonate()
        if impersonate.canImpersonate(with: url) {
            impersonate.impersonate(with: url)
        }

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

    func setupSession() {
        urlSessionClientProvider = {
            return InterceptingURLSessionClient()
        }
        setupAnalyticsAndTracking()
        bag += Localization.Locale.$currentLocale
            .onValue { [weak self] locale in
                ApplicationState.setPreferredLocale(locale)
                ApolloClient.acceptLanguageHeader = locale.acceptLanguageHeader
                self?.bag += ApolloClient.initAndRegisterClient()
            }

        ApolloClient.bundle = Bundle.main
        ApolloClient.acceptLanguageHeader = Localization.Locale.currentLocale.acceptLanguageHeader

        AskForRating().registerSession()
        CrossFrameworkCoordinator.setup()

        setupDebugger()
    }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Localization.Locale.currentLocale = ApplicationState.preferredLocale
        setupSession()
        hGraphQL.log = Logger.builder
            .sendNetworkInfo(true)
            .printLogsToConsole(true, usingFormat: .shortWith(prefix: "[Hedvig] "))
            .build()
        setupPresentableStoreLogger()

        log.info("Starting app")

        UIApplication.shared.registerForRemoteNotifications()

        let (launchView, launchFuture) = Launch.shared.materialize()
        window.rootView.addSubview(launchView)
        launchView.layer.zPosition = .greatestFiniteMagnitude - 2

        forceLogoutHook = {
            DispatchQueue.main.async {
                launchView.removeFromSuperview()

                ApplicationState.preserveState(.notLoggedIn)

                ApplicationContext.shared.hasFinishedBootstrapping = true
                Launch.shared.completeAnimationCallbacker.callAll()

                UIApplication.shared.appDelegate.logout()

                let toast = Toast(
                    symbol: .icon(hCoreUIAssets.infoShield.image),
                    body: L10n.forceLogoutMessageTitle,
                    subtitle: L10n.forceLogoutMessageSubtitle,
                    textColor: .black,
                    backgroundColor: .brand(.caution)
                )

                Toasts.shared.displayToast(toast: toast)
            }
        }

        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()

        launchView.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

        DefaultStyling.installCustom()

        UNUserNotificationCenter.current().delegate = self

        bag += launchFuture.valueSignal.onValue { _ in
            launchView.removeFromSuperview()
            ApplicationContext.shared.hasFinishedBootstrapping = true

            if Environment.hasOverridenDefault {
                let toast = Toast(
                    symbol: .icon(hCoreUIAssets.settingsIcon.image),
                    body: "Targeting \(Environment.current.displayName) environment",
                    textColor: .black,
                    backgroundColor: .brand(.caution)
                )

                self.bag += toast.onTap.onValue {
                    self.window.rootViewController?
                        .present(
                            UIHostingController(rootView: Debug()),
                            style: .detented(.medium, .large),
                            options: []
                        )
                }

                Toasts.shared.displayToast(toast: toast)
            }
        }
        setupExperiments()

        bag += ApplicationContext.shared.$isDemoMode.onValue { value in
            let store: UgglanStore = globalPresentableStoreContainer.get()
            TokenRefresher.shared.isDemoMode = value
            store.send(.setIsDemoMode(to: value))
        }
        let store: UgglanStore = globalPresentableStoreContainer.get()
        ApplicationContext.shared.$isDemoMode.value = store.state.isDemoMode
        TokenRefresher.shared.isDemoMode = store.state.isDemoMode

        observeNotificationsSettings()

        return true
    }

    private func setupExperiments() {
        self.bag += ApolloClient.initAndRegisterClient().valueSignal.map { _ in true }.plain()
            .atValue { _ in
                self.setupFeatureFlags(onComplete: { success in
                    DispatchQueue.main.async {
                        self.bag += self.window.present(AppJourney.main)
                    }
                })
            }
    }
}

extension ApolloClient {
    public static func initAndRegisterClient() -> Future<Void> {
        Self.initClients()
            .onValue { hApollo in
                Dependencies.shared.add(module: Module { AnalyticsCoordinator() })
                let paymentService = hPaymentServiceOctopus()
                let hForeverCodeService = hForeverCodeServiceOctopus()
                let hCampaignsService = hCampaingsServiceOctopus()
                let networkClient = NetworkClient()
                let messagesClient = FetchMessagesClientOctopus()
                let sendMessage = SendMessagesClientOctopus()
                Dependencies.shared.add(module: Module { hApollo.octopus })
                Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchMessagesClient in messagesClient })
                Dependencies.shared.add(module: Module { () -> SendMessageClient in sendMessage })
                let featureFlagsUnleash = FeatureFlagsUnleash(environment: Environment.current)
                Dependencies.shared.add(module: Module { hApollo.octopus })
                Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlagsUnleash })
                Dependencies.shared.add(
                    module: Module { () -> TravelInsuranceClient in TravelInsuranceClientOctopus() }
                )

                switch Environment.current {
                case .staging:
                    let hFetchClaimService = FetchClaimServiceOctopus()
                    Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                    Dependencies.shared.add(module: Module { () -> AdyenService in networkClient })
                    Dependencies.shared.add(module: Module { () -> hPaymentService in paymentService })
                    Dependencies.shared.add(module: Module { () -> hForeverCodeService in hForeverCodeService })
                    Dependencies.shared.add(module: Module { () -> hCampaignsService in hCampaignsService })
                    Dependencies.shared.add(module: Module { () -> hFetchClaimService in hFetchClaimService })
                    Dependencies.shared.add(module: Module { () -> hClaimFileUploadService in networkClient })
                case .production, .custom:
                    let hFetchClaimService = FetchClaimServiceOctopus()
                    Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                    Dependencies.shared.add(module: Module { () -> AdyenService in networkClient })
                    Dependencies.shared.add(module: Module { () -> hPaymentService in paymentService })
                    Dependencies.shared.add(module: Module { () -> hForeverCodeService in hForeverCodeService })
                    Dependencies.shared.add(module: Module { () -> hCampaignsService in hCampaignsService })
                    Dependencies.shared.add(module: Module { () -> hFetchClaimService in hFetchClaimService })
                    Dependencies.shared.add(module: Module { () -> hClaimFileUploadService in networkClient })

                }
            }
            .toVoid()
    }
}
