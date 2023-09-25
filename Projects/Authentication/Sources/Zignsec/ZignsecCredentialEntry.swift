import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ZignsecCredentialEntry: View {
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
        guard masking.isValid(text: store.state.zignsecState.personalNumber) else {
            return
        }

        store.send(.cancel)

        self.focusPersonalNumberField = false
        store.send(
            .zignsecStateAction(action: .setIsLoading(isLoading: true))
        )
        store.send(
            .zignsecStateAction(
                action: .startSession(
                    personalNumber: masking.unmaskedValue(
                        text: store.state.zignsecState.personalNumber
                    )
                )
            )
        )
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

                    PresentableStoreLens(
                        AuthenticationStore.self,
                        getter: { state in
                            state.zignsecState.credentialError
                        }
                    ) { credentialError in
                        hTextField(
                            masking: masking,
                            value: Binding(
                                AuthenticationStore.self,
                                getter: { state in
                                    state.zignsecState.personalNumber
                                },
                                setter: { personalNumber in
                                    .zignsecStateAction(action: .setPersonalNumber(personalNumber: personalNumber))
                                }
                            )
                        )
                        .focused($focusPersonalNumberField, equals: true) {
                            onSubmit()
                        }
                        .hTextFieldError(
                            credentialError ? L10n.zignsecCouldntStart : nil
                        )
                    }
                }
            }
        }
        .hFormAttachToBottom {
            PresentableStoreLens(
                AuthenticationStore.self,
                getter: { state in
                    state.zignsecState
                }
            ) { zignsecState in
                hSection {
                    hButton.LargeButton(type: .primary) {
                        onSubmit()
                    } content: {
                        hText(L10n.Login.continueButton)
                    }
                }
                .disabled(!masking.isValid(text: zignsecState.personalNumber))
                .hButtonIsLoading(zignsecState.isLoading)
            }
            .presentableStoreLensAnimation(.default)
        }
        .sectionContainerStyle(.transparent)
        .onAppear {
            self.focusPersonalNumberField = true
            store.send(.cancel)
        }
    }
}
