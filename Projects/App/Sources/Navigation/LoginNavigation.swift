import Apollo
import AppStateContainer
import AuthenticationCore
import AuthenticationUI
import Market
import Profile
import SwiftUI
import hCore
import hCoreUI

struct LoginNavigation: View {
    @Bindable var vm: NotLoggedViewModel
    @StateObject private var router = NavigationRouter()
    @State private var otpState = OTPState()

    var body: some View {
        hNavigationStack(router: router, options: .navigationBarHidden, tracking: LoginDetentType.notLoggedIn) {
            NotLoggedInView(vm: vm)
        }
        .detent(presented: $vm.showLanguagePicker, presentationStyle: .detent(style: [.height])) {
            LanguagePickerView {
                let store: ProfileStore = globalAppStateContainer.get()
                Task { await store.updateLanguage() }
                vm.showLanguagePicker = false
            } onCancel: {
                vm.showLanguagePicker = false
            }
            .navigationTitle(L10n.loginLanguagePreferences)
            .embededInNavigation(
                options: [.navigationType(type: .large)],
                tracking: LoginDetentType.languagePicker
            )
        }
        .detent(presented: $vm.showLogin, presentationStyle: .detent(style: [.large])) {
            BankIDLoginQRView {
                await handleDemoModeActivation()
            }
            .environment(otpState)
            .withDismissButton()
            .routerDestination(for: AuthenticationRouterType.self) { type in
                switch type {
                case .emailLogin:
                    OTPEntryView()
                        .environment(otpState)
                        .withDismissButton()
                case .otpCodeEntry:
                    OTPCodeEntryView()
                        .environment(otpState)
                        .withDismissButton()
                case let .error(message):
                    LoginErrorView(message: message)
                }
            }
            .embededInNavigation(
                options: .extendedNavigationWidth,
                tracking: String.init(describing: BankIDLoginQRView.self)
            )
        }
    }

    private func handleDemoModeActivation() async {
        let store: UgglanStore = globalAppStateContainer.get()
        store.isDemoMode = true
        DI.initAndRegisterClient()
    }
}

private enum LoginDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .notLoggedIn:
            return .init(describing: NotLoggedInView.self)
        case .languagePicker:
            return .init(describing: LanguagePickerView.self)
        }
    }

    case notLoggedIn
    case languagePicker
}
