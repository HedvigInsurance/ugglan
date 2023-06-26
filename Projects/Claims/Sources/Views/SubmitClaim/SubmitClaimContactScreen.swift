import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var phoneNumber: String
    @State var type: ClaimsFlowContactType?

    public init(
        model: FlowClaimPhoneNumberStepModel
    ) {
        self.phoneNumber = model.phoneNumber
    }
    public var body: some View {
        hForm {}
            .hFormTitle(.small, .customTitle, L10n.claimsConfirmNumberTitle)
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
                    .sectionContainerStyle(.transparent)
                    LoadingButtonWithContent(.postPhoneNumber) {
                        store.send(.phoneNumberRequest(phoneNumber: phoneNumber))
                        UIApplication.dismissKeyboard()
                    } content: {
                        hTextNew(L10n.saveAndContinueButtonLabel, style: .body)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding(.horizontal, 16)
                }
            }

            .hUseNewStyle
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
