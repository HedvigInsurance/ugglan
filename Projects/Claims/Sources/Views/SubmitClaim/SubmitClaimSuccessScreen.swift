import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSuccessScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        hForm {
            HStack {
                hText(L10n.Message.Claims.Record.ok, style: .body)
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

            /* TODO: FIX BUTTONS */
            HStack {

                Button {
                    store.send(.dissmissNewClaimFlow)
                } label: {
                    HStack {
                        hText(L10n.generalCloseButton, style: .body)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .padding([.top, .bottom], 10)
                    .frame(width: 180)
                    .background(hBackgroundColor.tertiary)
                    .cornerRadius(.defaultCornerRadius)
                    .hShadow()
                }

                Button {
                    store.send(.openFreeTextChat)
                } label: {
                    HStack {
                        hText(L10n.Message.Claims.Start.Select.From.user, style: .body)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .padding([.top, .bottom], 10)
                    .frame(width: 180)
                    .background(hBackgroundColor.tertiary)
                    .cornerRadius(.defaultCornerRadius)
                    .hShadow()
                }

                //                hButton.LargeButtonFilled {
                //                    store.send(.dissmissNewClaimFlow)
                //                } content: {
                //                    hText(L10n.generalCloseButton, style: .body)
                //                        .foregroundColor(hLabelColor.primary.inverted)
                //                }
                //                .frame(maxWidth: 50)
                //                .scaledToFit()
                //                .padding(.leading, 50)
                //                .frame(width: 80, alignment: .leading)

                //                hButton.LargeButtonFilled {
                //                    store.send(.openFreeTextChat)
                //                } content: {
                //
                //                    HStack {
                //                        hText(L10n.Message.Claims.Start.Select.From.user, style: .body)
                //                            .foregroundColor(hLabelColor.primary.inverted)
                //                    }
                //
                //                }
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

struct SubmitClaimSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSuccessScreen()
    }
}
