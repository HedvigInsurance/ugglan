import SwiftUI
import hCoreUI
import hCore

public struct LoginFail: View {
    @PresentableStore var store: AuthenticationStore
    
    public init (){}
    
    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColorNew.amberElement)
                VStack(spacing: 0) {
                    hText(L10n.somethingWentWrong)
                        .foregroundColor(hTextColorNew.primaryTranslucent)
                    hText("We cannot log you in via BankID right now, try again")
                        .foregroundColor(hTextColorNew.secondaryTranslucent)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, UIScreen.main.bounds.size.height / 3.0)
        }
        .hFormAttachToBottom {
            hButton.LargeButtonGhost {
                store.send(.cancel)
            } content: {
                hText(L10n.generalCloseButton)
            }
            .padding(.horizontal, 16)
        }
    }
}

struct LofinFail_Previews: PreviewProvider {
    static var previews: some View {
        LoginFail()
    }
}
