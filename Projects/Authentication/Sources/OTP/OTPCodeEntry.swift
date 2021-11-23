import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct OTPCodeEntry: View {
    @PresentableStore var store: AuthenticationStore
    @hTextFieldFocusState var focusCodeField: Bool? = true

    var codeBinding: Binding<String> {
        Binding(
            AuthenticationStore.self,
            getter: { state in
                state.otpState.code
            },
            setter: { code in
                .otpStateAction(action: .setCode(code: code))
            }
        )
    }

    public init() {}

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 50) {
                    VStack(spacing: 16) {
                        hText(L10n.Login.Title.checkYourEmail, style: .title1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ReadOTPState { state in
                            hText(
                                L10n.Login.Subtitle.verificationCodeEmail(state.email),
                                style: .body
                            )
                        }
                    }

                    VStack(spacing: 8) {
                        ReadOTPState { state in
                            OTPCodeDisplay(
                                code: state.code,
                                showRedBorders: state.codeErrorMessage != nil
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

                                    codeBinding.wrappedValue = String(onlyDigitsCode.prefix(6))
                                }
                            )
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded({ _ in
                                        focusCodeField = true
                                    })
                            )

                            if let errorMessage = state.codeErrorMessage {
                                hText(
                                    errorMessage,
                                    style: .footnote
                                )
                                .foregroundColor(hTintColor.red)
                                .transition(.opacity)
                            }

                            ResendOTPCode()
                        }
                        .presentableStoreLensAnimation(.default)
                    }
                }
            }
            .background(
                hTextField(
                    masking: .init(type: .digits),
                    value: codeBinding
                )
                .focused($focusCodeField, equals: true)
                .opacity(0)
            )
        }
        .hFormAttachToBottom {
            OpenEmailClientButton()
        }
        .overlay(OTPCodeLoadingOverlay())
        .sectionContainerStyle(.transparent)
    }
}
