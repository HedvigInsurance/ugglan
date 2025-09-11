import SwiftUI
import hCore
import hCoreUI

public struct OTPEntryView: View {
    @StateObject private var vm: OTPEntryViewModel = .init()
    @EnvironmentObject var otpVM: OTPState
    @EnvironmentObject var router: Router
    public init() {}

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 50) {
                    hText(
                        vm.title,
                        style: .displayXSLong
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    hTextField(
                        masking: vm.masking,
                        value: $otpVM.input
                    )
                    .focused($vm.focusInputField, equals: false) {
                        vm.onSubmit(otpState: otpVM)
                    }
                    .hTextFieldError(otpVM.otpInputErrorMessage)
                }
            }
        }
        .hFormAttachToBottom {
            hSection {
                hContinueButton {
                    vm.onSubmit(otpState: otpVM)
                }
                .hButtonIsLoading(otpVM.isLoading)
            }
            .disabled(!vm.masking.isValid(text: otpVM.input))
        }
        .sectionContainerStyle(.transparent)
        .onAppear {
            vm.focusInputField = true
            vm.router = router
        }
    }
}

@MainActor
class OTPEntryViewModel: ObservableObject {
    var authenticationService = AuthenticationService()
    @hTextFieldFocusState var focusInputField = false
    weak var router: Router?
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
