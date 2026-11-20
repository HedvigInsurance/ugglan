import AppStateContainer
import AuthenticationCore
import AuthenticationUI
import Combine
import ContractsCore
import Forever
import Home
import Market
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
    private var featureFlags: FeatureFlagsStore { vm.featureFlags }

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
            .showsTouchesWhileCaptured()
            .onAppear {
                ThemeOption.current.apply(animated: false)
            }
            .onOpenURL { url in
                handle(url: url)
            }
            .onChange(of: state) {
                vm.state = state
            }
            // On the root, so it stays presented while the logged in content is swapped for the switching screen
            .detent(item: $vm.powerOfAttorneySwitchLogin, presentationStyle: .detent(style: [.large])) { login in
                powerOfAttorneySwitchLogin(id: login.id)
            }
        }
    }

    /// The power of attorney BankID login, started from a logged in session. The member stays logged in until it
    /// completes, then the sessions are swapped.
    private func powerOfAttorneySwitchLogin(id: String) -> some View {
        BankIDLoginQRView(powerOfAttorneyId: id) { [weak vm] in
            vm?.switchToPowerOfAttorney()
        } onStartDemoMode: {
        }
        .withDismissButton()
        .routerDestination(for: AuthenticationRouterType.self) { type in
            if case let .error(message) = type {
                LoginErrorView(message: message)
            }
        }
        .embededInNavigation(
            options: .extendedNavigationWidth,
            tracking: String.init(describing: BankIDLoginQRView.self)
        )
    }

    @ViewBuilder
    private var rootContent: some View {
        if featureFlags.osVersionTooLow {
            UpdateOSScreen()
                .trackViewName(name: .init(describing: UpdateOSScreen.self))
        } else if featureFlags.isUpdateNecessary {
            UpdateAppScreen(onSelected: {}, withoutDismissButton: true)
                .trackViewName(name: .init(describing: UpdateAppScreen.self))
        } else if let switchingAccount = vm.switchingAccount {
            SwitchingAccountScreen(switchingTo: switchingAccount)
                .transition(.opacity)
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
                .environment(\.actingPowerOfAttorney, vm.powerOfAttorney)
                .environment(
                    \.switchBackToOwnAccount,
                    vm.canSwitchBackToOwnAccount
                        ? SwitchBackToOwnAccountAction { [weak vm] in vm?.switchBackToOwnAccount() } : nil
                )
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
    // Observed, so swapping in the fresh store after logout re-renders MainNavigation against it
    var featureFlags = Dependencies.featureFlags()
    @ObservationIgnored lazy var notLoggedInVm = NotLoggedViewModel()
    @ObservationIgnored var loggedInVm = LoggedInNavigationViewModel()
    @ObservationIgnored private var pushNotificationCancellable: AnyCancellable?
    @ObservationIgnored private var deepLinkCancellable: AnyCancellable?
    @ObservationIgnored var powerOfAttorneyLinkCancellable: AnyCancellable?
    @ObservationIgnored private lazy var powerOfAttorneyLinkCoordinator = PowerOfAttorneyLinkCoordinator(mainVm: self)
    /// Set when someone logged in with a power of attorney link
    private(set) var powerOfAttorney: ActingPowerOfAttorney? {
        didSet {
            loggedInVm.actingPowerOfAttorney = powerOfAttorney
        }
    }
    /// Whether the member switched to a power of attorney from their own session and can return to it
    private(set) var canSwitchBackToOwnAccount = false
    /// Shows the switching screen instead of the tabs while the session is swapped for another one
    private(set) var switchingAccount: SwitchingAccountScreen.Destination?
    /// The power of attorney login opened from a link while logged in
    var powerOfAttorneySwitchLogin: NotLoggedViewModel.PowerOfAttorneyLogin?
    @ObservationIgnored let authenticationService = AuthenticationService()

    @ObservationIgnored @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var stateToShow = ApplicationState.currentState ?? .notLoggedIn
    @ObservationIgnored var state: ApplicationState.Screen = ApplicationState.currentState ?? .notLoggedIn {
        didSet {
            Task {
                switch state {
                case .loggedIn:
                    await startLoggedInSession()
                case .notLoggedIn:
                    await ApplicationContext.shared.setValue(to: false)
                    powerOfAttorneySwitchLogin = nil
                    powerOfAttorney = nil
                    canSwitchBackToOwnAccount = false
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
                        // logout reset the feature flags store, so the fresh one needs its own client; the profile
                        // store is empty now, so the flags and experiments are no longer the member's
                        self.featureFlags = Dependencies.featureFlags()
                        self.checkForFeatureFlags()
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

    private func startLoggedInSession() async {
        UIApplication.shared.registerForRemoteNotifications()
        await ApplicationContext.shared.setValue(to: true)
        withAnimation {
            hasLaunchFinished = false
        }
        await loadPowerOfAttorney()
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
    }

    /// Opens the power of attorney login from a link while logged in. The member stays logged in until it completes.
    func startPowerOfAttorneySwitch(id: String) {
        powerOfAttorneySwitchLogin = .init(id: id)
    }

    /// The power of attorney login completed and its session replaced the previous one: drops what that session left
    /// behind and starts the new one.
    func switchToPowerOfAttorney() {
        powerOfAttorneySwitchLogin = nil
        switchSession(to: .powerOfAttorney) { true }
    }

    /// Ends the power of attorney session and goes back to the member's own, without logging in again.
    func switchBackToOwnAccount() {
        switchSession(to: .ownAccount) { [authenticationService] in
            await authenticationService.restoreSavedSession()
        }
    }

    /// Shows the switching screen while `swapSession` replaces the current session, then starts the new one.
    /// `swapSession` returns `false` when the session stayed as it was.
    private func switchSession(
        to destination: SwitchingAccountScreen.Destination,
        swapSession: @escaping () async -> Bool
    ) {
        guard switchingAccount == nil else { return }
        Task {
            // Tear down the previous session's views before its stores are dropped
            withAnimation {
                switchingAccount = destination
                hasLaunchFinished = false
            }
            // The switching screen stays up at least this long, even when the switch finishes sooner
            let minimumDisplay = Task { try? await Task.sleep(for: .seconds(3)) }
            if await swapSession() {
                // Logged out of the previous session while the switching screen is up, so none of its data survives
                await ApplicationContext.shared.setValue(to: false)
                powerOfAttorney = nil
                canSwitchBackToOwnAccount = false
                notLoggedInVm = .init()
                analyticsService.clearUserId()
                analyticsService = AnalyticsService()
                appDelegate.clearDataForSwitchedSession()
                // Recreated only after the container reset, see the `.notLoggedIn` case
                loggedInVm = .init()
                featureFlags = Dependencies.featureFlags()
                await startLoggedInSession()
            } else {
                canSwitchBackToOwnAccount = false
                hasLaunchFinished = true
            }
            await minimumDisplay.value
            withAnimation {
                switchingAccount = nil
            }
        }
    }

    @MainActor
    init() {
        Task { @MainActor [weak self] in
            await UIApplication.shared.appDelegate.initialSetup()
            // Before the launch finishes, so a limited power of attorney session never shows the logged in app
            await self?.loadPowerOfAttorney()
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
        whenShowing(.loggedIn, after: isColdStart ? 2 : 1, storingIn: \.pushNotificationCancellable) { [weak self] in
            self?.loggedInVm.handle(notification: notification)
        }
    }

    // The notification can arrive before the screen's tree exists, so the handler waits for it
    // and then for `delay`, which gives that tree time to settle. It runs once: the subscription is
    // dropped as soon as it fires, and skipped entirely when the screen is already shown.
    func whenShowing(
        _ screen: ApplicationState.Screen,
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
        guard stateToShow != screen else {
            schedule()
            return
        }
        self[keyPath: keyPath] = publisher(for: \.stateToShow)
            .first { $0 == screen }
            .sink { [weak self] _ in
                self?[keyPath: keyPath] = nil
                schedule()
            }
    }

    @objc func handleDeepLink(notification: Notification) {
        guard let deepLinkUrl = notification.object as? URL else { return }

        let timeSinceLaunch = appDelegate.applicationLaunchTimestamp.timeIntervalSinceNow
        let isColdStart = abs(timeSinceLaunch) < 1
        // Power of attorney links log in someone else, so they mustn't wait for (and then run in) a logged in app
        if DeepLink.getType(from: deepLinkUrl) == .powerOfAttorney {
            if featureFlags.isPowerOfAttorneyEnabled {
                powerOfAttorneyLinkCoordinator.handle(deepLinkUrl, isColdStart: isColdStart)
            }
            return
        }
        whenShowing(.loggedIn, after: isColdStart ? 2 : 0.2, storingIn: \.deepLinkCancellable) { [weak self] in
            self?.loggedInVm.handleDeepLink(deepLinkUrl)
        }
    }

    /// Reads who is using the app with a power of attorney, stored by the auth service when that login completed.
    private func loadPowerOfAttorney() async {
        guard state == .loggedIn else {
            powerOfAttorney = nil
            canSwitchBackToOwnAccount = false
            return
        }
        powerOfAttorney = await authenticationService.getPowerOfAttorney()
        canSwitchBackToOwnAccount = powerOfAttorney != nil ? await authenticationService.hasSavedSession() : false
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
