import SwiftUI
import hCore
import hCoreUI

public struct OTPCodeEntryView: View {
    @StateObject private var vm = OTPCodeEntryViewModel()
    @EnvironmentObject var otpVM: OTPState
    @EnvironmentObject var router: Router
    public init() {}

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 50) {
                    VStack(spacing: 16) {
                        hText(L10n.Login.Title.checkYourEmail, style: .displayXSLong)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        hText(
                            L10n.Login.Subtitle.verificationCodeEmail(otpVM.maskedEmail ?? L10n.authOtpYourEmail),
                            style: .body1
                        )
                    }
                    VStack(spacing: 8) {
                        OTPCodeDisplay(
                            code: otpVM.code,
                            showRedBorders: otpVM.codeErrorMessage != nil
                        )
                        .background(
                            PasteView {
                                guard let pasteBoardValue = UIPasteboard.general.string else {
                                    return
                                }

                                let onlyDigitsCode =
                                    pasteBoardValue.components(
                                        separatedBy: CharacterSet.decimalDigits.inverted
                                    )
                                    .joined()

                                otpVM.code = String(onlyDigitsCode.prefix(6))
                            }
                        )
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    vm.focusCodeField = true
                                }
                        )

                        if let errorMessage = otpVM.codeErrorMessage {
                            hText(
                                errorMessage,
                                style: .label
                            )
                            .foregroundColor(hSignalColor.Red.text)
                            .transition(.opacity)
                        }

                        ResendOTPCode(otpVM: otpVM)
                            .environmentObject(otpVM)
                    }
                }
            }
            .background(
                hTextField(
                    masking: .init(type: .digits),
                    value: $otpVM.code
                )
                .focused($vm.focusCodeField, equals: true)
                .opacity(0)
            )
        }
        .hFormAttachToBottom {
            OpenEmailClientButton()
                .environmentObject(otpVM)
        }
        .overlay(
            OTPCodeLoadingOverlay(otpVM: otpVM)
        )
        .sectionContainerStyle(.transparent)
        .onChange(of: otpVM.code) { _ in
            vm.check(otpState: otpVM)
        }
        .onAppear {
            vm.router = router
        }
    }
}

@MainActor
class OTPCodeEntryViewModel: ObservableObject {
    private var authenticationService = AuthenticationService()
    @hTextFieldFocusState var focusCodeField: Bool? = true
    var router: Router?
    func check(otpState: OTPState) {
        let code = otpState.code
        Task {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        otpState.codeErrorMessage = nil
        if code.count == 6 {
            Task { @MainActor [weak self, weak otpState] in
                otpState?.isLoading = true
                do {
                    if let service = self?.authenticationService, let otpState = otpState {
                        let code = try await service.submit(otpState: otpState)
                        try await service.exchange(code: code)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        ApplicationState.preserveState(.loggedIn)
                        ApplicationState.state = .loggedIn
                        self?.router?.dismiss()
                    }
                } catch {
                    otpState?.codeErrorMessage = error.localizedDescription
                }
                otpState?.isLoading = false
            }
        }
    }
}
