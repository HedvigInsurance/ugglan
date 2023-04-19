import SwiftUI
import hCore
import hCoreUI

struct ClaimFailureScreen: View {
    @PresentableStore var store: SubmitClaimStore
    init() {}
    
    var body: some View {
        
        hForm {
            Image(uiImage: hCoreUIAssets.warningTriangle.image)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding([.bottom, .top], 4)
            
            hText(L10n.HomeTab.errorTitle, style: .title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.bottom, 4)
            
            hText(L10n.HomeTab.errorBody, style: .body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        .hFormAttachToBottom {
            
            VStack {
                hButton.LargeButtonOutlined {
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .padding(.bottom, 4)
                hButton.LargeButtonFilled {
                    store.send(.dissmissNewClaimFlow)
                    store.send(.openFreeTextChat)
                } content: {
                    hText(L10n.openChat, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
            }
            .padding([.leading, .trailing, .bottom], 16)
        }
    }
}

struct TerminationFailScreen_Previews: PreviewProvider {
    static var previews: some View {
        ClaimFailureScreen()
    }
}
