//
//  OTPEmailEntry.swift
//  Authentication
//
//  Created by Sam Pettersson on 2021-11-12.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCoreUI
import hCore

public struct OTPEmailEntry: View {
    @PresentableStore var store: AuthenticationStore
    @hTextFieldFocusState var focusEmailField = true
    
    public init() {}
    
    var emailMasking: Masking {
        Masking(type: .email)
    }
    
    func onSubmit() {
        guard emailMasking.isValid(text: store.state.otpState.email) else {
            return
        }
        
        self.focusEmailField = false
        store.send(.otpStateAction(action: .setLoading(isLoading: true)))
        store.send(.otpStateAction(action: .submitEmail))
    }
    
    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 50) {
                    hText("Please enter your email address below.", style: .title1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    hTextField(
                        masking: emailMasking,
                        value: Binding(
                            AuthenticationStore.self,
                            getter: { state in
                                state.otpState.email
                            },
                            setter: { email in
                                .otpStateAction(action: .setEmail(email: email))
                            }
                        )
                    ).focused($focusEmailField, equals: true) {
                        onSubmit()
                    }
                }
            }
        }.hFormAttachToBottom {
            ReadOTPState { state in
                hSection {
                    hButton.LargeButtonFilled {
                        onSubmit()
                    } content: {
                        hText("Continue")
                    }.hButtonIsLoading(state.isLoading)
                }.disabled(!emailMasking.isValid(text: state.email))
            }.presentableStoreLensAnimation(.default)
        }
        .sectionContainerStyle(.transparent)
        .onAppear {
            self.focusEmailField = true
        }
    }
}
