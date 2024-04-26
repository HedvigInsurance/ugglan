import SwiftUI
import hCore

@main
struct MainNavigationJourney: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var vm = MainNavigationViewModel()
    @AppStorage("applicationState") public var state: ApplicationState.Screen = .notLoggedIn
    var body: some Scene {
        WindowGroup {
            if vm.hasLaunchFinished {
                switch state {
                case .loggedIn, .impersonation:
                    LoggedInNavigation()
                default:
                    LoginNavigation()
                }
            } else {
                ProgressView()
            }
        }
    }
}

class MainNavigationViewModel: ObservableObject {
    @Published var hasLaunchFinished = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        appDelegate.setupFeatureFlags { [weak self] success in
            DispatchQueue.main.async {
                self?.hasLaunchFinished = true
            }
        }
    }
}

#Preview{
    Launch()
}
