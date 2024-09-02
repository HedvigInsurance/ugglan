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
                hButton.LargeButton(type: .primary) {
                    vm.onSubmit(otpState: otpVM)
                } content: {
                    hText(L10n.Login.continueButton)
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

class OTPEntryViewModel: ObservableObject {
    var authenticationService = AuthenticationService()
    @hTextFieldFocusState var focusInputField = false
    weak var router: Router?
    var masking: Masking {
        switch Localization.Locale.currentLocale.value.market {
        case .dk:
            return Masking(type: .danishPersonalNumber)
        case .no:
            return Masking(type: .norwegianPersonalNumber)
        case .se:
            return Masking(type: .email)
        }
    }

    var title: String {
        switch Localization.Locale.currentLocale.value.market {
        case .dk, .no:
            return L10n.zignsecLoginScreenTitle
        case .se:
            return L10n.Login.enterYourEmailAddress
        }
    }

    func onSubmit(otpState: OTPState) {
        guard masking.isValid(text: otpState.input) else {
            return
        }
        self.focusInputField = false
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
                    self?.router?.push(AuthentificationRouterType.otpCodeEntry)
                }
            } catch let error {
                otpState?.isLoading = false
                otpState?.otpInputErrorMessage = error.localizedDescription
            }
        }
    }
}
