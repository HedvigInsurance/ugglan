import Authentication
import Contracts
import EditCoInsured
import EditCoInsuredShared
import Forever
import Home
import Market
import MoveFlow
import Payment
import Presentation
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
            Group {
                if vm.hasLaunchFinished {
                    switch vm.stateToShow {
                    case .loggedIn:
                        LoggedInNavigation(vm: vm.loggedInVm)
                            .environmentObject(vm)
                    case .impersonation:
                        ImpersonationSettings()
                    default:
                        LoginNavigation(vm: vm.notLoggedInVm)
                    }
                } else {
                    ProgressView()
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

    private func handle(url: URL) {
        if url.relativePath.contains("login-failure") {
            vm.notLoggedInVm.router.push(AuthentificationRouterType.error(message: L10n.authenticationBankidLoginError))
        }
        NotificationCenter.default.post(name: .openDeepLink, object: url)
        appDelegate.handleURL(url: url)
    }
}

class MainNavigationViewModel: ObservableObject {
    @Published var hasLaunchFinished = false
    lazy var notLoggedInVm = NotLoggedViewModel()
    var loggedInVm = LoggedInNavigationViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Published var stateToShow = ApplicationState.currentState ?? .notLoggedIn
    var state: ApplicationState.Screen = ApplicationState.currentState ?? .notLoggedIn {
        didSet {
            Task {
                switch state {
                case .loggedIn:
                    withAnimation {
                        hasLaunchFinished = false
                    }
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    await contractStore.sendAsync(.fetchContracts)
                    await fetchFeatureFlag()
                    withAnimation {
                        hasLaunchFinished = true
                    }
                case .notLoggedIn:
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
        Task {
            await fetchFeatureFlag()
            withAnimation {
                hasLaunchFinished = true
            }
        }
    }

    func fetchFeatureFlag() async {
        await withCheckedContinuation { [weak self] data in
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
