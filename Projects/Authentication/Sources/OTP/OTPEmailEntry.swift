import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct OTPEmailEntry: View {
    @PresentableStore var store: AuthenticationStore
    @hTextFieldFocusState var focusEmailField = true

    public init() {}

    var emailMasking: Masking {
        Masking(type: .email)
    }

    func onSubmit() {
        guard emailMasking.isValid(text: store.state.otpState.email ?? "") else {
            return
        }

        self.focusEmailField = false
        store.send(.otpStateAction(action: .setLoading(isLoading: true)))
        store.send(.otpStateAction(action: .submitOtpData))
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 50) {
                    hText(
                        L10n.Login.enterYourEmailAddress,
                        style: .title1
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    ReadOTPState { state in
                        hTextField(
                            masking: emailMasking,
                            value: Binding(
                                AuthenticationStore.self,
                                getter: { state in
                                    state.otpState.email ?? ""
                                },
                                setter: { email in
                                    .otpStateAction(action: .setEmail(email: email))
                                }
                            )
                        )
                        .focused($focusEmailField, equals: true) {
                            onSubmit()
                        }
                        .hTextFieldError(state.otpInputErrorMessage)
                    }
                    .presentableStoreLensAnimation(.default)
                }
            }
        }
        .hFormAttachToBottom {
            ReadOTPState { state in
                hSection {
                    hButton.LargeButton(type: .primary) {
                        onSubmit()
                    } content: {
                        hText(L10n.Login.continueButton)
                    }
                    .hButtonIsLoading(state.isLoading)
                }
                .disabled(!emailMasking.isValid(text: state.email ?? ""))
            }
            .presentableStoreLensAnimation(.default)
        }
        .sectionContainerStyle(.transparent)
        .onAppear {
            self.focusEmailField = true
        }
    }
}

public struct OTPSSNEntry: View {
    public init() {}

    @PresentableStore var store: AuthenticationStore
    @hTextFieldFocusState var focusPersonalNumberField = true

    var masking: Masking {
        switch Localization.Locale.currentLocale.market {
        case .dk:
            return Masking(type: .danishPersonalNumber)
        case .no:
            return Masking(type: .norwegianPersonalNumber)
        default:
            return Masking(type: .none)
        }
    }

    func onSubmit() {
        guard masking.isValid(text: store.state.otpState.personalNumber ?? "") else {
            return
        }

        store.send(.cancel)

        self.focusPersonalNumberField = false
        store.send(.otpStateAction(action: .setLoading(isLoading: true)))
        store.send(.otpStateAction(action: .submitOtpData))
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 50) {
                    hText(
                        L10n.zignsecLoginScreenTitle,
                        style: .title1
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ReadOTPState { state in
                        hTextField(
                            masking: masking,
                            value: Binding(
                                AuthenticationStore.self,
                                getter: { state in
                                    state.otpState.personalNumber ?? ""
                                },
                                setter: { personalNumber in
                                        .otpStateAction(action: .setPersonalNumber(personalNumber: personalNumber))
                                }
                            )
                        )
                        .focused($focusPersonalNumberField, equals: true) {
                            onSubmit()
                        }
                        .hTextFieldError(state.personalNumber)
                    }
                    .presentableStoreLensAnimation(.default)
                }
            }
        }
        .hFormAttachToBottom {
            ReadOTPState { state in
                hSection {
                    hButton.LargeButton(type: .primary) {
                        onSubmit()
                    } content: {
                        hText(L10n.Login.continueButton)
                    }
                    .hButtonIsLoading(state.isLoading)
                }
                .disabled(!masking.isValid(text: state.personalNumber ?? ""))
            }
            .presentableStoreLensAnimation(.default)
        }
        .sectionContainerStyle(.transparent)
        .onAppear {
            self.focusPersonalNumberField = true
        }
    }
}

#Preview {
    OTPSSNEntry()
}
