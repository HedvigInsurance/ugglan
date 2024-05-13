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
                        LoggedInNavigation()
                            .environmentObject(vm)
                    case .impersonation:
                        ImpersonationSettings()
                    default:
                        LoginNavigation()
                    }
                } else {
                    ProgressView()
                }
            }
            .onOpenURL { url in
                appDelegate.handleURL(url: url)
            }
            .onChange(of: state) { value in
                vm.state = state
            }
        }
    }

    private func openUrl(url: URL) {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contractStore.send(.fetchContracts)
        let homeStore: HomeStore = globalPresentableStoreContainer.get()
        homeStore.send(.fetchQuickActions)
        var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if urlComponent?.scheme == nil {
            urlComponent?.scheme = "https"
        }
        let schema = urlComponent?.scheme
        if let finalUrl = urlComponent?.url {
            if schema == "https" || schema == "http" {
                let vc = SFSafariViewController(url: finalUrl)
                vc.modalPresentationStyle = .pageSheet
                vc.preferredControlTintColor = .brand(.primaryText())
                UIApplication.shared.getTopViewController()?.present(vc, animated: true)
            } else {
                UIApplication.shared.open(url)
            }
        }
    }
}

class MainNavigationViewModel: ObservableObject {
    @Published var hasLaunchFinished = false
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
