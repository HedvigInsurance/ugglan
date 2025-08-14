import Apollo
import Authentication
import Market
import PresentableStore
import Profile
import SwiftUI
import hCore
import hCoreUI

struct LoginNavigation: View {
    @ObservedObject var vm: NotLoggedViewModel
    @StateObject private var router = Router()
    @StateObject private var otpState = OTPState()

    var body: some View {
        RouterHost(router: router, options: .navigationBarHidden, tracking: LoginDetentType.notLoggedIn) {
            NotLoggedInView(vm: vm)
        }
        .detent(presented: $vm.showLanguagePicker, transitionType: .detent(style: [.height])) {
            LanguagePickerView {
                let store: ProfileStore = globalPresentableStoreContainer.get()
                store.send(.updateLanguage)
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
        .detent(presented: $vm.showLogin, transitionType: .detent(style: [.large])) {
            BankIDLoginQRView {
                await handleDemoModeActivation()
            }
            .environmentObject(otpState)
            .withDismissButton()
            .routerDestination(for: AuthenticationRouterType.self) { type in
                switch type {
                case .emailLogin:
                    OTPEntryView()
                        .environmentObject(otpState)
                        .withDismissButton()
                case .otpCodeEntry:
                    OTPCodeEntryView()
                        .environmentObject(otpState)
                        .withDismissButton()
                case let .error(message):
                    LoginErrorView(message: message)
                }
            }
            .embededInNavigation(tracking: Localization.Locale.currentLocale.value.code)
        }
    }

    private func handleDemoModeActivation() async {
        let store: UgglanStore = globalPresentableStoreContainer.get()
        await store.sendAsync(.setIsDemoMode(to: true))
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
