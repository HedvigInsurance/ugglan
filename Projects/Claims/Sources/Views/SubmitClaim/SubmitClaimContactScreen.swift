import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var phoneNumber: String
    @State var type: ClaimsFlowContactType?

    public init(
        model: FlowClaimPhoneNumberStepModel? = nil
    ) {
        self.phoneNumber = model?.phoneNumber ?? "0987654"
    }
    public var body: some View {

        LoadingViewWithContent(.postPhoneNumber) {
            hForm {
            }
            .hUseNewStyle
            .hFormTitle(.small, L10n.claimsConfirmNumberTitle)
            .hFormAttachToBottom {
                VStack(spacing: 24) {
                    hSection {
                        hFloatingTextField(
                            masking: Masking(type: .digits),
                            value: $phoneNumber,
                            equals: $type,
                            focusValue: .phoneNumber,
                            placeholder: L10n.phoneNumberRowTitle
                        )
                    }

                    hButton.LargeButtonFilled {
                        store.send(.phoneNumberRequest(phoneNumber: phoneNumber))
                        UIApplication.dismissKeyboard()
                    } content: {
                        hTextNew(L10n.generalContinueButton, style: .body)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding([.leading, .trailing], 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .onChange(of: type) { newValue in
            if newValue == nil {
                UIApplication.dismissKeyboard()
                store.send(.phoneNumberRequest(phoneNumber: phoneNumber))
            } else if newValue == .phoneNumber {
                UIApplication.dismissKeyboard()
            }
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

struct SubmitClaimContactScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimContactScreen(model: nil)
    }
}
