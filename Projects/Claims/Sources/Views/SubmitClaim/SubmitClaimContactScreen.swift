import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View, KeyboardReadable {
    @PresentableStore var store: SubmitClaimStore
    @State var phoneNumber: String
    @State var type: ClaimsFlowContactType?
    @State var keyboardEnabled: Bool = false

    @State private var isKeyboardVisible = false

    public init(
        model: FlowClaimPhoneNumberStepModel
    ) {
        self.phoneNumber = model.phoneNumber
    }
    public var body: some View {
        hForm {}
            .hFormTitle(.small, .title1, L10n.claimsConfirmNumberTitle)
            .hFormAttachToBottom {
                VStack(spacing: 16) {
                    hSection {
                        hFloatingTextField(
                            masking: Masking(type: .digits),
                            value: $phoneNumber,
                            equals: $type,
                            focusValue: .phoneNumber,
                            placeholder: L10n.phoneNumberRowTitle
                        )
                    }
                    .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                        keyboardEnabled = newIsKeyboardEnabled
                    }
                    .sectionContainerStyle(.transparent)
                    .disableOn(SubmitClaimStore.self, [.postPhoneNumber])
                    if keyboardEnabled {
                        hButton.LargeButtonPrimary {
                            UIApplication.dismissKeyboard()
                        } content: {
                            hText(L10n.generalSaveButton)
                        }
                        .padding(.horizontal, 16)

                    } else {
                        LoadingButtonWithContent(SubmitClaimStore.self, ClaimsLoadingType.postPhoneNumber) {
                            store.send(.phoneNumberRequest(phoneNumber: phoneNumber))
                            UIApplication.dismissKeyboard()
                        } content: {
                            hText(L10n.generalContinueButton, style: .body)
                        }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
            }
    }
}

enum ClaimsFlowContactType: hTextFieldFocusStateCompliant {
    static var last: ClaimsFlowContactType {
        return ClaimsFlowContactType.phoneNumber
    }

    var next: ClaimsFlowContactType? {
        switch self {
        default:
            return nil
        }
    }

    case phoneNumber
}

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
