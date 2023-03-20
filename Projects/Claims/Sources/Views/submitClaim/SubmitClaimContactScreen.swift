import Combine
import Contracts
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View {

    @PresentableStore var store: ClaimsStore
    @State var phoneNumber: String

    public init(
        phoneNumber: String
    ) {
        self.phoneNumber = phoneNumber
    }

    public var body: some View {

        hForm {
            HStack(spacing: 0) {
                hText(L10n.Message.Claims.Ask.phone, style: .body)
                    .foregroundColor(hLabelColor.primary)
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
                    store.send(.submitClaimPhoneNumber(phoneNumberInput: phoneNumber))
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding([.leading, .trailing], 16)
            }
        }
    }
}
