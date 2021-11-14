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
import Combine
import Flow
import Presentation

extension Binding {
    init<S: Store>(
        _ storeType: S.Type,
        getter: @escaping (_ state: S.State) -> Value,
        setter: @escaping (_ value: Value) -> S.Action
    ) {
        let store: S = globalPresentableStoreContainer.get()
        
        self.init {
            getter(store.stateSignal.value)
        } set: { newValue, _ in
            store.send(setter(newValue))
        }
    }
}

struct OTPCodeLoadingOverlay: View {
    var body: some View {
        PresentableStoreLens(
            AuthenticationStore.self,
            getter: { state in
                state.otpState.isLoading
            }
        ) { isLoading in
            if isLoading {
                HStack {
                    WordmarkActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(hBackgroundColor.primary.opacity(0.7))
                .cornerRadius(.defaultCornerRadius)
                .edgesIgnoringSafeArea(.top)
            }
        }.presentableStoreLensAnimation(.default)
    }
}

struct ReadOTPState<Content: View>: View {
    var content: (_ state: OTPState) -> Content
    
    init(@ViewBuilder _ content: @escaping (_ state: OTPState) -> Content) {
        self.content = content
    }
    
    var body: some View {
        PresentableStoreLens(
            AuthenticationStore.self,
            getter: { state in
                state.otpState
            }
        ) { state in
            content(state)
        }
    }
}

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
                        hText("Click the log in button in the email or enter the 6-digit code we've sent to johndoe@gmail.com.", style: .body)
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
                        }.presentableStoreLensAnimation(.default)
                    }
                }
            }.background(
                hTextField(
                    masking: .init(type: .digits),
                    value: Binding(
                        AuthenticationStore.self,
                        getter: { state in
                            state.otpState.code
                        }, setter: { code in
                            .otpStateAction(action: .setCode(code: code))
                        }
                    )
                )
                .focused($focusCodeField, equals: true)
                .opacity(0)
            )
        }.hFormAttachToBottom {
            ReadOTPState { state in
                hSection {
                    hButton.LargeButtonFilled {
                        
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
