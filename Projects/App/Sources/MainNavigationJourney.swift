import Contracts
import Presentation
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

#Preview{
    Launch()
}
