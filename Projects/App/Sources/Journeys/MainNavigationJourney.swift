import Authentication
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
struct MainNavigationJourney: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var vm = MainNavigationViewModel()
    @AppStorage(ApplicationState.key) public var state: ApplicationState.Screen = .notLoggedIn
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if vm.osVersionTooLow {
                        UpdateOSScreen()
                            .trackViewName(name: .init(describing: UpdateOSScreen.self))
                    } else if vm.shouldUpdateApp {
                        UpdateAppScreen(onSelected: {}, withoutDismissButton: true)
                            .trackViewName(name: .init(describing: UpdateAppScreen.self))
                    } else if vm.hasLaunchFinished {
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
                }
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
            .onChange(of: state) { value in
                vm.state = state
            }
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

class MainNavigationViewModel: ObservableObject {
    @Published var hasLaunchFinished = false {
        didSet {
            loggedInVm.hasLaunchFinished.send(hasLaunchFinished)
        }
    }
    @Published var showLaunchScreen = true
    @Published var shouldUpdateApp = false
    @Published var osVersionTooLow = false
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
                    ApplicationContext.shared.setValue(to: true)
                    withAnimation {
                        hasLaunchFinished = false
                    }
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    await contractStore.sendAsync(.fetchContracts)
                    await checkForFeatureFlags()
                    let profileStore: ProfileStore = globalPresentableStoreContainer.get()

                    await profileStore.sendAsync(.fetchMemberDetails)
                    await profileStore.sendAsync(.updateLanguage)
                    await checkForFeatureFlags()
                    Task {
                        try? await AnalyticsService().fetchAndSetUserId()
                    }
                    withAnimation {
                        hasLaunchFinished = true
                    }
                case .notLoggedIn:
                    ApplicationContext.shared.setValue(to: false)
                    notLoggedInVm = .init()
                    loggedInVm = .init()
                    appDelegate.logout()
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
            await self?.checkForFeatureFlags()
            withAnimation(.easeInOut) {
                self?.hasLaunchFinished = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                withAnimation(.easeInOut(duration: 0.5)) {
                    self?.showLaunchScreen = false
                }
            }
        }
        if state == .loggedIn {
            ApplicationContext.shared.setValue(to: true)
            UIApplication.shared.registerForRemoteNotifications()
            showLaunchScreen = false
        }
        appDelegate.configureAppBadgeTracking()
    }

    private func checkForFeatureFlags() async {
        await fetchFeatureFlag()
        shouldUpdateApp = Dependencies.featureFlags().isUpdateNecessary
        osVersionTooLow = Dependencies.featureFlags().osVersionTooLow
    }

    func fetchFeatureFlag() async {
        await withCheckedContinuation { @MainActor [weak self] data in
            if let self = self {
                self.appDelegate.setupFeatureFlags { _ in
                    data.resume()
                }
            } else {
                data.resume()
            }
        }
    }
}
