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
                        hText("Check your email.", style: .title1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        hText(
                            "Click the log in button in the email or enter the 6-digit code we've sent to johndoe@gmail.com.",
                            style: .body
                        )
                    }

                    VStack(spacing: 8) {
                        ReadOTPState { state in
                            OTPCodeDisplay(
                                code: state.code,
                                showRedBorders: state.errorMessage != nil
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

                            if let errorMessage = state.errorMessage {
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
