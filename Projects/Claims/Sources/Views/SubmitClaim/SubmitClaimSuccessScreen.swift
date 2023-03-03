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
        }
        .hFormAttachToBottom {

            HStack(spacing: 10) {
                if #available(iOS 15.0, *) {
                    hButton.LargeButtonFilled {
                        store.send(.dissmissNewClaimFlow)
                    } content: {
                        hText(L10n.generalCloseButton, style: .body)
                            .foregroundColor(hLabelColor.primary.inverted)

                    }
                    //                                    .frame(maxWidth: .infinity, alignment: .center)
                    //                    .padding(.leading, 16)
                    //                    .padding(.trailing, 16)
                    //                    .background(.blue)
                } else {
                    // Fallback on earlier versions
                }

                if #available(iOS 15.0, *) {
                    hButton.LargeButtonFilled {
                        store.send(.openFreeTextChat)
                    } content: {
                        hText(L10n.Message.Claims.Start.Select.From.user, style: .body)
                            .foregroundColor(hLabelColor.primary.inverted)
                    }
                    //                    .background(.red)
                    //                    .padding(.trailing, 16)
                } else {
                    // Fallback on earlier versions
                }
                //                .frame(maxWidth: .infinity, alignment: .trailing)
                //                .padding(.trailing, 26)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            //            .padding(.leading, 46)
            //            .padding(.trailing, 46)
            //            .frame(maxWidth: .infinity, alignment: .center)
            //            .background(hBackgroundColor.tertiary)
            //            .frame(maxWidth: .infinity, alignment: .leading)
            //            .padding([.top, .leading, .trailing], 16)
            //            .padding(.bottom, 40)

        }
    }
}

struct SubmitClaimSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSuccessScreen()
    }
}
