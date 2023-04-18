import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View {

    @PresentableStore var store: SubmitClaimStore
    @State var phoneNumber: String

    public init(
        model: FlowClaimPhoneNumberStepModel
    ) {
        self.phoneNumber = model.phoneNumber
    }
    public var body: some View {

        LoadingViewWithContent(.postPhoneNumber) {
            hForm {
                HStack(spacing: 0) {
                    hText(L10n.Message.Claims.Ask.phone, style: .body)
                        .foregroundColor(hLabelColor.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding([.trailing, .leading], 12)
                        .padding([.top, .bottom], 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(hBackgroundColor.tertiary)
                .cornerRadius(12)
                .padding(.leading, 16)
                .padding(.trailing, 32)
                .padding(.top, 20)
                .hShadow()
            }
            .hFormAttachToBottom {
                VStack {
                    HStack {
                        VStack {
                            TextField(phoneNumber, text: $phoneNumber)
                                .font(.title2)
                                .foregroundColor(hLabelColor.primary)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .onReceive(Just(phoneNumber)) { newValue in
                                    let filteredNumbers = newValue.filter { "0123456789".contains($0) }
                                    if filteredNumbers != newValue {
                                        self.phoneNumber = filteredNumbers
                                    }
                                }
                            hText(L10n.phoneNumberRowTitle, style: .footnote)
                                .foregroundColor(hLabelColor.primary)
                        }
                        .padding([.top, .bottom], 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(hBackgroundColor.tertiary)
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 16)
                    hButton.LargeButtonFilled {
                        store.send(.phoneNumberRequest(phoneNumber: phoneNumber))
                        UIApplication.dismissKeyboard()
                    } content: {
                        hText(L10n.generalContinueButton, style: .body)
                            .foregroundColor(hLabelColor.primary.inverted)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding([.leading, .trailing], 16)
                    .padding(.bottom, 6)
                }
            }
        }
    }
}
