import SwiftUI
import hCore
import hCoreUI

public struct LoginFail: View {
    @PresentableStore var store: AuthenticationStore
    let message: String?
    public init(message: String?) {
        self.message = message
    }

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)
                VStack(spacing: 0) {
                    hText(L10n.somethingWentWrong)
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText(message ?? L10n.authenticationBankidLoginError)
                        .foregroundColor(hTextColor.secondaryTranslucent)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, UIScreen.main.bounds.size.height / 3.0)
        }
        .hFormAttachToBottom {
            hButton.LargeButton(type: .ghost) {
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
        LoginFail(message: nil)
    }
}
