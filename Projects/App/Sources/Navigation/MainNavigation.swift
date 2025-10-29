import Authentication
import Combine
import Contracts
import Forever
import Home
import Market
import MoveFlow
import Payment
import PresentableStore
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
    @StateObject var vm = MainNavigationViewModel()
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
                if vm.stateToShow.isOneOf([.notLoggedIn]) {
                    LaunchScreen()
                        .foregroundColor(logoColor)
                        .zIndex(2)
                }
            }
            .onOpenURL { url in
                handle(url: url)
            }
            .onChange(of: state) { _ in
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
                .environmentObject(vm)
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
class MainNavigationViewModel: ObservableObject {
    @Published var hasLaunchFinished = false {
        didSet {
            loggedInVm.hasLaunchFinished.send(hasLaunchFinished)
        }
    }
    private var analyticsService = AnalyticsService()
    @Published var showLaunchScreen = true
    lazy var notLoggedInVm = NotLoggedViewModel()
    var loggedInVm = LoggedInNavigationViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Published var stateToShow = ApplicationState.currentState ?? .notLoggedIn
    var state: ApplicationState.Screen = ApplicationState.currentState ?? .notLoggedIn {
        didSet {
            Task {
                switch state {
                case .loggedIn:
                    UIApplication.shared.registerForRemoteNotifications()
                    await ApplicationContext.shared.setValue(to: true)
                    withAnimation {
                        hasLaunchFinished = false
                    }
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    await contractStore.sendAsync(.fetchContracts)
                    let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                    await profileStore.sendAsync(.fetchMemberDetails)
                    await profileStore.sendAsync(.updateLanguage)
                    checkForFeatureFlags()
                    Task {
                        try? await analyticsService.fetchAndSetUserId()
                    }
                    withAnimation {
                        hasLaunchFinished = true
                    }
                    loggedInVm.actionAfterLogin()
                case .notLoggedIn:
                    await ApplicationContext.shared.setValue(to: false)
                    notLoggedInVm = .init()
                    loggedInVm = .init()
                    appDelegate.logout()
                    analyticsService = AnalyticsService()
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
        ToolbarOptionType.newOfferNotification.resetTooltipDisplayState()
        ToolbarOptionType.chatNotification.resetTooltipDisplayState()
    }

    private func hideLaunchScreen() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showLaunchScreen = false
        }
    }

    private var featureFlagTask: Task<(), Error>?
    private func checkForFeatureFlags() {
        featureFlagTask?.cancel()
        featureFlagTask = Task { [weak self] in
            do {
                try await self?.appDelegate.setupFeatureFlags()
            } catch {
                try await Task.sleep(nanoseconds: 1_000_000_000)
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
        if #available(iOS 16.0, *) {
            Task {
                try await UNUserNotificationCenter.current().setBadgeCount(0)
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
