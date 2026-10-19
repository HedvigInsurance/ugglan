import AuthenticationCore
import SwiftUI
import hCore
import hCoreUI

public struct OTPEntryView: View {
    @StateObject private var vm: OTPEntryViewModel = .init()
    @EnvironmentObject var otpVM: OTPState
    @EnvironmentObject var router: NavigationRouter
    public init() {}

    public var body: some View {
        hForm {}
            .hFormTitle(title: .init(.small, .body1, vm.title, alignment: .leading))
            .hFormAttachToBottom {
                hSection {
                    hFloatingTextField(
                        masking: vm.masking,
                        value: $otpVM.input,
                        equals: vm.$focusInputField,
                        focusValue: true,
                        placeholder: L10n.emailRowTitle,
                        error: $otpVM.otpInputErrorMessage
                    ) {
                        vm.onSubmit(otpState: otpVM)
                    }
                }
                hSection {
                    hContinueButton {
                        vm.onSubmit(otpState: otpVM)
                    }
                    .hButtonIsLoading(otpVM.isLoading)
                }
                .disabled(!vm.masking.isValid(text: otpVM.input))
            }
            .hFormContentPosition(.bottom)
            .sectionContainerStyle(.transparent)
            .onAppear {
                vm.focusInputField = true
                vm.router = router
            }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AuthenticationService in AuthenticationService() })
    return OTPEntryView()
        .environmentObject(OTPState())
        .environmentObject(NavigationRouter())
}

@MainActor
class OTPEntryViewModel: ObservableObject {
    var authenticationService = AuthenticationService()
    @hTextFieldFocusState var focusInputField = false
    weak var router: NavigationRouter?
    var masking: Masking {
        Masking(type: .email)
    }

    var title: String {
        L10n.Login.enterYourEmailAddress
    }

    func onSubmit(otpState: OTPState) {
        guard masking.isValid(text: otpState.input) else {
            return
        }
        focusInputField = false
        otpState.isLoading = true
        Task { @MainActor [weak self, weak otpState] in
            do {
                if let otpState = otpState, let data = try await self?.authenticationService.start(with: otpState) {
                    otpState.code = ""
                    otpState.verifyUrl = data.verifyUrl
                    otpState.resendUrl = data.resendUrl
                    otpState.isLoading = false
                    otpState.codeErrorMessage = nil
                    otpState.otpInputErrorMessage = nil
                    otpState.canResendAt = Date().addingTimeInterval(60)
                    otpState.isResending = false
                    otpState.maskedEmail = data.maskedEmail
                    self?.router?.push(AuthenticationRouterType.otpCodeEntry)
                }
            } catch {
                otpState?.isLoading = false
                otpState?.otpInputErrorMessage = error.localizedDescription
            }
        }
    }
}
