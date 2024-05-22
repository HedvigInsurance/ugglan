import Apollo
import Authentication
import Chat
import Claims
import Combine
import Contracts
import CoreDependencies
import DatadogLogs
import EditCoInsured
import Flow
import Forever
import Form
import Foundation
import MoveFlow
import Payment
import Presentation
import Profile
import SwiftUI
import TerminateContracts
import TravelCertificate
import UserNotifications
import hCore
import hCoreUI
import hGraphQL

#if PRESENTATION_DEBUGGER
    #if compiler(>=5.5)
        import PresentationDebugSupport
    #endif
#endif

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    var localeCancellable: AnyCancellable?
    var featureFlagsCancellables = Set<AnyCancellable>()
    let window: UIWindow = {
        var window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        return window
    }()

    private func clearData() {
        ApolloClient.cache = InMemoryNormalizedCache()

        // remove all persisted state
        globalPresentableStoreContainer.deletePersistanceContainer()

        // create new store container to remove all old store instances
        globalPresentableStoreContainer = PresentableStoreContainer()

        ApolloClient.initAndRegisterClient()
    }

    func logout() {
        let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
        ugglanStore.send(.setIsDemoMode(to: false))
        Task {
            let authenticationService: AuthentificationService = Dependencies.shared.resolve()
            do {
                try await authenticationService.logout()
            } catch _ {

            }
        }
        ApolloClient.deleteToken()
        clearData()
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
        NotificationCenter.default.post(name: .openDeepLink, object: url)
        return true
    }

    func registerForPushNotifications(completed: @escaping () -> Void) {
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
                    completed()
                }
            )

    }

    func handleURL(url: URL) {
        let impersonate = Impersonate()
        if impersonate.canImpersonate(with: url) {
            let store: UgglanStore = globalPresentableStoreContainer.get()
            store.send(.setIsDemoMode(to: false))
            Task {
                setupSession()
                await impersonate.impersonate(with: url)

            }
        }
    }

    func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        handleURL(url: url)
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
        ApolloClient.initAndRegisterClient()
        urlSessionClientProvider = {
            return InterceptingURLSessionClient()
        }
        setupAnalyticsAndTracking()
        localeCancellable = Localization.Locale.currentLocale
            .sink(receiveValue: { locale in
                ApplicationState.setPreferredLocale(locale)
                ApolloClient.acceptLanguageHeader = locale.acceptLanguageHeader
            })

        ApolloClient.bundle = Bundle.main
        ApolloClient.acceptLanguageHeader = Localization.Locale.currentLocale.value.acceptLanguageHeader
        AskForRating().registerSession()
        setupDebugger()
    }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Localization.Locale.currentLocale.value = ApplicationState.preferredLocale
        setupSession()
        TokenRefresher.shared.onRefresh = { token in
            let authService: AuthentificationService = Dependencies.shared.resolve()
            try await authService.exchange(refreshToken: token)
        }
        let config = Logger.Configuration(
            service: "ios",
            networkInfoEnabled: true,
            bundleWithRumEnabled: true,
            bundleWithTraceEnabled: true,
            remoteLogThreshold: .info,
            consoleLogFormat: .shortWith(prefix: "[Hedvig] ")
        )
        let datadogLogger = Logger.create(with: config)
        hGraphQL.log = DatadogLogger(datadogLogger: datadogLogger)

        setupPresentableStoreLogger()

        log.info("Starting app")

        UIApplication.shared.registerForRemoteNotifications()
        forceLogoutHook = { [weak self] in
            if ApplicationState.currentState != .notLoggedIn {
                DispatchQueue.main.async {
                    ApplicationState.preserveState(.notLoggedIn)
                    ApplicationContext.shared.hasFinishedBootstrapping = true
                    self?.logout()
                    let toast = Toast(
                        symbol: .icon(hCoreUIAssets.infoIconFilled.image),
                        body: L10n.forceLogoutMessageTitle,
                        textColor: .brand(.secondaryText),
                        backgroundColor: .brand(.opaqueFillOne, style: .dark),
                        symbolColor: .brand(.secondaryText)
                    )
                    Toasts.shared.displayToast(toast: toast)
                }
            }
        }

        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        DefaultStyling.installCustom()

        UNUserNotificationCenter.current().delegate = self
        observeNotificationsSettings()
        return true
    }
}
