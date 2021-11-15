import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct OTPCodeEntry: View {
    @hTextFieldFocusState var focusCodeField: Bool = true

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
                            .onTapGesture {
                                focusCodeField = true
                            }

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
                    value: Binding(
                        AuthenticationStore.self,
                        getter: { state in
                            state.otpState.code
                        },
                        setter: { code in
                            .otpStateAction(action: .setCode(code: code))
                        }
                    )
                )
                .focused($focusCodeField, equals: true)
                .opacity(0)
            )
        }
        .hFormAttachToBottom {
            ReadOTPState { state in
                hSection {
                    hButton.LargeButtonFilled {
                        let mailURL = URL(string: "message://")!
                        if UIApplication.shared.canOpenURL(mailURL) {
                            UIApplication.shared.open(
                                mailURL,
                                options: [:],
                                completionHandler: nil
                            )
                        }
                    } content: {
                        hText("Open email")
                    }
                }
                .offset(x: 0, y: state.code.isEmpty ? 0 : 150)
                .opacity(state.code.isEmpty ? 1 : 0)
                .animation(.spring(), value: state.code)
            }
        }
        .overlay(OTPCodeLoadingOverlay())
        .sectionContainerStyle(.transparent)
    }
}
