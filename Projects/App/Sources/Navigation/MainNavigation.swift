import AppStateContainer
import Combine
import Contracts
import Forever
import Home
import Market
import MoveFlow
import Payment
import Profile
import SafariServices
import SwiftUI
import hCore
import hCoreUI

@main
struct MainNavigation: App {
    init() {
        DI.initServices()
    }

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var vm = MainNavigationViewModel()
    @AppStorage(ApplicationState.key) var state: ApplicationState.Screen = .notLoggedIn
    @InjectObservableObject var featureFlags: FeatureFlags

    var body: some Scene {
        WindowGroup {
            ZStack {
                rootContent
                if vm.showLaunchScreen {
                    BackgroundView()
                        .ignoresSafeArea()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                        .zIndex(1)
                }
                if vm.stateToShow.isOneOf([.notLoggedIn]) && !featureFlags.osVersionTooLow
                    && !featureFlags.isUpdateNecessary
                {
                    LaunchScreen()
                        .foregroundColor(logoColor)
                        .zIndex(2)
                }
            }
            .onAppear {
                ThemeOption.current.apply(animated: false)
            }
            .onOpenURL { url in
                handle(url: url)
            }
            .onChange(of: state) {
                vm.state = state
            }
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        if featureFlags.osVersionTooLow {
            UpdateOSScreen()
                .trackViewName(name: .init(describing: UpdateOSScreen.self))
        } else if featureFlags.isUpdateNecessary {
            UpdateAppScreen(onSelected: {}, withoutDismissButton: true)
                .trackViewName(name: .init(describing: UpdateAppScreen.self))
        } else if vm.hasLaunchFinished {
            loggedInContent
        }
    }

    @ViewBuilder
    private var loggedInContent: some View {
        switch vm.stateToShow {
        case .loggedIn:
            LoggedInNavigation(vm: vm.loggedInVm)
                .environment(vm)
        case .impersonation:
            ImpersonationSettings()
                .trackViewName(name: .init(describing: ImpersonationSettings.self))
        default:
            LoginNavigation(vm: vm.notLoggedInVm)
        }
    }

    @hColorBuilder
    var logoColor: some hColor {
        if vm.showLaunchScreen {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.primary.colorFor(.light, .base)
        }
    }

    private func handle(url: URL) {
        NotificationCenter.default.post(name: .openDeepLink, object: url)
        appDelegate.handleURL(url: url)
    }
}

@MainActor
@Observable
class MainNavigationViewModel {
    var hasLaunchFinished = false
    @ObservationIgnored private var analyticsService = AnalyticsService()
    var showLaunchScreen = true
    @ObservationIgnored lazy var notLoggedInVm = NotLoggedViewModel()
    @ObservationIgnored var loggedInVm = LoggedInNavigationViewModel()
    @ObservationIgnored private var pushNotificationCancellable: AnyCancellable?
    @ObservationIgnored private var deepLinkCancellable: AnyCancellable?

    @ObservationIgnored @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var stateToShow = ApplicationState.currentState ?? .notLoggedIn
    @ObservationIgnored var state: ApplicationState.Screen = ApplicationState.currentState ?? .notLoggedIn {
        didSet {
            Task {
                switch state {
                case .loggedIn:
                    UIApplication.shared.registerForRemoteNotifications()
                    await ApplicationContext.shared.setValue(to: true)
                    withAnimation {
                        hasLaunchFinished = false
                    }
                    let contractStore: ContractStore = globalAppStateContainer.get()
                    await contractStore.fetchContracts()
                    let profileStore: ProfileStore = globalAppStateContainer.get()
                    await profileStore.fetchMemberDetails()
                    await profileStore.updateLanguage()
                    checkForFeatureFlags()
                    Task {
                        try? await analyticsService.fetchAndSetUserId()
                    }
                    withAnimation {
                        hasLaunchFinished = true
                    }
                case .notLoggedIn:
                    await ApplicationContext.shared.setValue(to: false)
                    notLoggedInVm = .init()
                    analyticsService.clearUserId()
                    analyticsService = AnalyticsService()
                    // Recreate loggedInVm only AFTER clearData() has reset the
                    // container — otherwise the new loggedInVm's nav VMs (e.g.
                    // HomeNavigationViewModel.editStakeholdersVm) would
                    // eagerly fetch and pin the about-to-be-discarded stores
                    // via their property initializers' globalAppStateContainer.get(...).
                    // Run in a detached Task so the view switch happens immediately
                    // while the auth network logout completes in the background.
                    Task {
                        await self.appDelegate.logout()
                        self.loggedInVm = .init()
                    }
                default:
                    break
                }
                withAnimation {
                    self.stateToShow = state
                }
            }
        }
    }

    @MainActor
    init() {
        Task { @MainActor [weak self] in
            await UIApplication.shared.appDelegate.initialSetup()
            self?.setCachedUserIdIfLoggedIn()
            self?.checkForFeatureFlags()
            withAnimation(.easeInOut) {
                self?.hasLaunchFinished = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.hideLaunchScreen()
            }
        }

        if state == .loggedIn {
            Task {
                await ApplicationContext.shared.setValue(to: true)
                UIApplication.shared.registerForRemoteNotifications()
                showLaunchScreen = false
            }
        }
        configureAppBadgeTracking()

        // we want to show it initially when app launches if there is any
        ToolbarOptionType.crossSell(hasNewOffer: false).resetTooltipDisplayState()
        ToolbarOptionType.chat(hasUnread: false).resetTooltipDisplayState()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePushNotification),
            name: .handlePushNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeepLink),
            name: .openDeepLink,
            object: nil
        )
    }

    @objc func handlePushNotification(notification: Notification) {
        let timeSinceLaunch = appDelegate.applicationLaunchTimestamp.timeIntervalSinceNow
        /// If the app was launched less than 1 second ago, it's a cold start (e.g. opened via push or deeplink)
        let isColdStart = abs(timeSinceLaunch) < 1
        whenLoggedIn(after: isColdStart ? 2 : 1, storingIn: \.pushNotificationCancellable) { [weak self] in
            self?.loggedInVm.handle(notification: notification)
        }
    }

    // The notification can arrive before the logged-in tree exists, so the handler waits for it
    // and then for `delay`, which gives that tree time to settle. It runs once: the subscription is
    // dropped as soon as it fires, and skipped entirely when the app is already logged in.
    private func whenLoggedIn(
        after delay: Double,
        storingIn keyPath: ReferenceWritableKeyPath<MainNavigationViewModel, AnyCancellable?>,
        perform action: @escaping @MainActor () -> Void
    ) {
        func schedule() {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(delay))
                action()
            }
        }
        guard stateToShow != .loggedIn else {
            schedule()
            return
        }
        self[keyPath: keyPath] = publisher(for: \.stateToShow)
            .first { $0 == .loggedIn }
            .sink { [weak self] _ in
                self?[keyPath: keyPath] = nil
                schedule()
            }
    }

    @objc func handleDeepLink(notification: Notification) {
        guard let deepLinkUrl = notification.object as? URL else { return }

        let timeSinceLaunch = appDelegate.applicationLaunchTimestamp.timeIntervalSinceNow
        let isColdStart = abs(timeSinceLaunch) < 1
        whenLoggedIn(after: isColdStart ? 2 : 0.2, storingIn: \.deepLinkCancellable) { [weak self] in
            self?.loggedInVm.handleDeepLink(deepLinkUrl)
        }
    }

    // On a cold start the `state` didSet never fires, so the user id is restored from the cached member details.
    // Must run after `initialSetup()`, since Datadog and Firebase are configured there.
    private func setCachedUserIdIfLoggedIn() {
        guard state == .loggedIn else { return }
        let profileStore: ProfileStore = globalAppStateContainer.get()
        if let userId = profileStore.memberDetails?.id {
            analyticsService.setWith(userId: userId)
        }
    }

    private func hideLaunchScreen() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showLaunchScreen = false
        }
    }

    @ObservationIgnored private var featureFlagTask: Task<(), Error>?
    private func checkForFeatureFlags() {
        featureFlagTask?.cancel()
        featureFlagTask = Task { [weak self] in
            do {
                try await self?.appDelegate.setupFeatureFlags()
            } catch let exception {
                log.info("Failed loading unleash experiments \(exception)")
                try await Task.sleep(for: .seconds(1))
                try Task.checkCancellation()
                self?.checkForFeatureFlags()
            }
        }
    }

    func configureAppBadgeTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetBadge),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetBadge),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetBadge),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    @objc func resetBadge() {
        UserDefaults(suiteName: "group.\(Bundle.main.bundleIdentifier!)")?.set(1, forKey: "count")
        Task {
            try? await UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
