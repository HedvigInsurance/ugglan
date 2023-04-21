import Adyen
import AdyenActions
import Apollo
import Authentication
import Claims
import CoreDependencies
import Datadog
import DatadogCrashReporting
import Disk
import Flow
import Form
import Foundation
import Hero
import OdysseyKit
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

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
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
                ChatState.shared = ChatState()
                self.bag += self.window.present(AppJourney.main)
            }
    }

    func logout() {
        hAnalyticsEvent.loggedOut().send()
        bag.dispose()

        let authenticationStore: AuthenticationStore = globalPresentableStoreContainer.get()
        authenticationStore.send(.logout)

        ApolloClient.deleteToken()
        self.presentMainJourney()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        hAnalyticsEvent.appShutdown().send()
        NotificationCenter.default.post(Notification(name: .applicationWillTerminate))
        Thread.sleep(forTimeInterval: 3)
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
        self.handleDeepLink(url)
        return true
    }

    func registerForPushNotifications() -> Future<Void> {
        Future { completion in
            UNUserNotificationCenter.current()
                .getNotificationSettings { settings in
                    let store: UgglanStore = globalPresentableStoreContainer.get()
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
                                let store: UgglanStore = globalPresentableStoreContainer.get()
                                store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
                            }
                        completion(.success)

                        self.trackNotificationPermission()
                    }
                )

            return NilDisposer()
        }
    }

    func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        if url.relativePath.contains("login-failure") {
            let authenticationStore: AuthenticationStore = globalPresentableStoreContainer.get()
            authenticationStore.send(.loginFailure)
        }

        let adyenRedirect = RedirectComponent.applicationDidOpen(from: url)

        if adyenRedirect { return adyenRedirect }

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

        setupPresentableStoreLogger()
        setupAnalyticsAndTracking()

        bag += Localization.Locale.$currentLocale
            .atOnce()
            .onValue { locale in
                ApplicationState.setPreferredLocale(locale)
                ApolloClient.acceptLanguageHeader = locale.acceptLanguageHeader

                ApolloClient.initAndRegisterClient()
                    .always {
                        ChatState.shared = ChatState()
                        self.performUpdateLanguage()
                    }
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

        hGraphQL.log = Logger.builder
            .sendNetworkInfo(true)
            .printLogsToConsole(true, usingFormat: .shortWith(prefix: "[Hedvig] "))
            .build()

        setupSession()

        log.info("Starting app")

        UIApplication.shared.registerForRemoteNotifications()

        hAnalyticsEvent.identify()
        hAnalyticsEvent.appStarted().send()

        let (launchView, launchFuture) = Launch.shared.materialize()
        window.rootView.addSubview(launchView)
        launchView.layer.zPosition = .greatestFiniteMagnitude - 2

        forceLogoutHook = {
            DispatchQueue.main.async {
                launchView.removeFromSuperview()

                ApplicationState.preserveState(.marketPicker)

                ApplicationContext.shared.hasFinishedBootstrapping = true
                Launch.shared.completeAnimationCallbacker.callAll()

                UIApplication.shared.appDelegate.logout()

                let toast = Toast(
                    symbol: .icon(hCoreUIAssets.infoShield.image),
                    body: L10n.forceLogoutMessageTitle,
                    subtitle: L10n.forceLogoutMessageSubtitle,
                    textColor: .black,
                    backgroundColor: .brand(.regularCaution)
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
                    backgroundColor: .brand(.regularCaution)
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

        ApolloClient.migrateOldTokenIfNeeded()
            .onValue { _ in
                self.trackNotificationPermission()
                self.setupHAnalyticsExperiments()

                self.bag += ApplicationContext.shared.$hasLoadedExperiments
                    .atOnce()
                    .onValue { isLoaded in
                        guard let isLoaded else { return }
                        if isLoaded {
                            self.bag += ApolloClient.initAndRegisterClient().valueSignal.map { _ in true }.plain()
                                .atValue { _ in
                                    self.initOdyssey()
                                    
                                    Dependencies.shared.add(module: Module { AnalyticsCoordinator() })
                                    
                                    AnalyticsCoordinator().setUserId()
                                    self.bag += self.window.present(AppJourney.main)
                                }
                        }else {
                            let alert = Alert(
                                title: L10n.somethingWentWrong,
                                message: L10n.General.errorBody,
                                actions: [
                                    Alert.Action(
                                        title: L10n.generalRetry,
                                        action: {
                                            self.setupHAnalyticsExperiments()
                                        }
                                    )
                                ]
                            )

                            self.bag += self.window.present(ActivityIndicator(style: .large, color: hLabelColor.primary).disposableHostingJourney.onPresent({
                                Journey(alert).onPresent {
                                    Launch.shared.completeAnimationCallbacker.callAll()
                                }
                            }))
                            
                        }
                    }
            }
        return true
    }
}

extension ApolloClient {
    public static func initAndRegisterClient() -> Future<Void> {
        Self.initClients()
            .onValue { hApollo in
                let odysseyNetworkClient = OdysseyNetworkClient()
                Dependencies.shared.add(module: Module { hApollo.giraffe })
                Dependencies.shared.add(module: Module { hApollo.octopus })
                Dependencies.shared.add(module: Module { () -> FileUploaderClient in odysseyNetworkClient })
            }
            .toVoid()
    }
}
