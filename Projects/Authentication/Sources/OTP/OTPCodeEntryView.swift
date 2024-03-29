import SwiftUI
import hCore
import hCoreUI

public struct OTPCodeEntryView: View {
    @StateObject private var vm = OTPCodeEntryViewModel()
    @ObservedObject var otpVM: OTPState
    @PresentableStore var store: AuthenticationStore

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 50) {
                    VStack(spacing: 16) {
                        hText(L10n.Login.Title.checkYourEmail, style: .title1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        hText(
                            L10n.Login.Subtitle.verificationCodeEmail(otpVM.maskedEmail ?? L10n.authOtpYourEmail),
                            style: .body
                        )
                    }
                    VStack(spacing: 8) {
                        OTPCodeDisplay(
                            code: otpVM.code,
                            showRedBorders: otpVM.codeErrorMessage != nil
                        )
                        .background(
                            PasteView {
                                guard let pasteBoardValue = UIPasteboard.general.value else {
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
                                .onEnded({ _ in
                                    vm.focusCodeField = true
                                })
                        )

                        if let errorMessage = otpVM.codeErrorMessage {
                            hText(
                                errorMessage,
                                style: .footnote
                            )
                            .foregroundColor(hSignalColor.redText)
                            .transition(.opacity)
                        }

                        ResendOTPCode(otpVM: otpVM)
                            .environmentObject(store.otpState)
                    }
                    .presentableStoreLensAnimation(.default)
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
        }
        .overlay(
            OTPCodeLoadingOverlay(otpVM: otpVM)
        )
        .sectionContainerStyle(.transparent)
        .onChange(of: otpVM.code) { newValue in
            vm.check(otpState: otpVM)
        }
    }
}

class OTPCodeEntryViewModel: ObservableObject {
    @PresentableStore private var store: AuthenticationStore
    @Inject private var service: AuthentificationService
    @hTextFieldFocusState var focusCodeField: Bool? = true

    func check(otpState: OTPState) {
        let code = otpState.code
        Task {
            let generator = await UIImpactFeedbackGenerator(style: .light)
            await generator.impactOccurred()
        }
        otpState.codeErrorMessage = nil
        if code.count == 6 {
            Task { @MainActor [weak self, weak otpState] in
                otpState?.isLoading = true
                do {
                    if let service = self?.service, let otpState = otpState {
                        let code = try await service.submit(otpState: otpState)
                        try await service.exchange(code: code)
                        self?.store.send(.navigationAction(action: .authSuccess))
                    }
                } catch let error {
                    otpState?.codeErrorMessage = error.localizedDescription
                }
                otpState?.isLoading = false
            }
        }
    }
}
