import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View {

    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {

        hForm {
            HStack(spacing: 0) {
                hText(L10n.Message.Claims.Ask.phone)
                    .padding([.trailing, .leading], 12)
                    .padding([.top, .bottom], 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 32)
            .padding(.top, 20)
        }

        .hFormAttachToBottom {

            VStack {

                HStack {
                    VStack {
                        hText("0712345678", style: .title2)
                        hText(L10n.phoneNumberRowTitle, style: .footnote)
                    }
                    .padding([.top, .bottom], 5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .background(hBackgroundColor.tertiary)
                .cornerRadius(12)
                .padding([.leading, .trailing], 16)

                hButton.LargeButtonFilled {
                    store.send(.submitClaimOccuranceScreen)
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

struct SubmitClaimContactScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimContactScreen()
    }
}
