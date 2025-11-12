import Apollo
import Authentication
import Chat
import Claims
import Combine
import Contracts
import CoreDependencies
import DatadogLogs
import Forever
import Foundation
import MoveFlow
import Payment
import PresentableStore
import Profile
import SwiftUI
import TerminateContracts
import TravelCertificate
@preconcurrency import UserNotifications
import hCore
import hCoreUI
import hGraphQL
import HedvigShared

@MainActor
class AppDelegate: UIResponder, UIApplicationDelegate {
    var cancellables = Set<AnyCancellable>()
    private var localizationObserverTask: AnyCancellable?

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

        DI.initAndRegisterClient()
    }

    func logout() {
        cancellables.removeAll()
        UIApplication.shared.unregisterForRemoteNotifications()
        let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
        ugglanStore.send(.setIsDemoMode(to: false))
        Task { @MainActor in
            let authenticationService = AuthenticationService()
            do {
                try await authenticationService.logout()
                await ApolloClient.deleteToken()
                clearData()
            } catch _ {
                await ApolloClient.deleteToken()
                clearData()
            }
        }
    }

    func applicationWillTerminate(_: UIApplication) {
        NotificationCenter.default.post(Notification(name: .applicationWillTerminate))
        Thread.sleep(forTimeInterval: 3)
    }

    func applicationDidEnterBackground(_: UIApplication) {}

    func application(
        _: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        NotificationCenter.default.post(name: .openDeepLink, object: url)
        return true
    }

    func registerForPushNotifications() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let store: ProfileStore = globalPresentableStoreContainer.get()
        store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if settings.authorizationStatus == .denied {
            DispatchQueue.main.async { Dependencies.urlOpener.open(settingsUrl) }
        } else {
            do {
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                _ = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
            } catch _ {}
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let store: ProfileStore = globalPresentableStoreContainer.get()
            store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
        }
    }

    func handleURL(url: URL) {
        let impersonate = Impersonate()
        if impersonate.canImpersonate(with: url) {
            let store: UgglanStore = globalPresentableStoreContainer.get()
            store.send(.setIsDemoMode(to: false))
            Task {
                await setupSession()
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

    func setupPresentableStoreLogger() {
        globalPresentableStoreContainer.logger = { message in
            Task { @MainActor in
                log.info(message)
            }
        }
    }

    func setupSession() async {
        urlSessionTaskDeleage = {
            InterceptingURLSessionClient()
        }
        await DI.initNetworkClients()
        DI.initAndRegisterClient()

        setupAnalyticsAndTracking()

        localizationObserverTask = Localization.Locale.currentLocale
            .receive(on: RunLoop.main)
            .sink { locale in
                ApplicationState.setPreferredLocale(locale)
                ApolloClient.acceptLanguageHeader = locale.acceptLanguageHeader
                let dateService = DateService()
                Dependencies.shared.add(module: Module { () -> DateService in dateService })
            }

        ApolloClient.acceptLanguageHeader = Localization.Locale.currentLocale.value.acceptLanguageHeader
        AskForRating().registerSession()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApolloClient.bundle = Bundle.main
        setLiquidGlassStatus()
        Localization.Locale.currentLocale.send(ApplicationState.preferredLocale)
        application.accessibilityLanguage = Localization.Locale.currentLocale.value.accessibilityLanguageCode
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        DefaultStyling.installCustom()
        
        UNUserNotificationCenter.current().delegate = self
        observeNotificationsSettings()
        Main_nativeKt.doInitKoin(
            accessTokenFetcher: KeychainAccessTokenFetcher()
        )
        return true
    }

    private func setLiquidGlassStatus() {
        isLiquidGlassEnabled = {
            if #available(iOS 26.0, *) {
                return !(Bundle.main.object(forInfoDictionaryKey: "UIDesignRequiresCompatibility") as? Bool ?? true)
            } else {
                return false
            }
        }()
    }

    func initialSetup() async {
        await setupSession()
        TokenRefresher.shared.onRefresh = { token in
            let authService = AuthenticationService()
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
        hGraphQL.graphQlLogger = DatadogLogger(datadogLogger: datadogLogger)
        log = DatadogLogger(datadogLogger: datadogLogger)

        setupPresentableStoreLogger()

        log.info("Starting app")

        forceLogoutHook = { [weak self] in
            if ApplicationState.currentState != .notLoggedIn {
                self?.dismissAllVCs()
                DispatchQueue.main.async {
                    ApplicationState.preserveState(.notLoggedIn)
                    ApplicationState.state = .notLoggedIn
                    self?.logout()

                    let toast = ToastBar(
                        type: .neutral,
                        text: L10n.forceLogoutMessageTitle
                    )
                    Toasts.shared.displayToastBar(toast: toast)
                }
            }
        }
    }

    private func dismissAllVCs() {
        Task {
            var hasPresentedVC = true
            while hasPresentedVC {
                let vcToDismiss = UIApplication.shared.getRootViewController()?.presentedViewController
                if let vcToDismiss {
                    vcToDismiss.dismiss(animated: true)
                } else {
                    hasPresentedVC = false
                }
                try await Task.sleep(seconds: 0.05)
            }
        }
    }
}
