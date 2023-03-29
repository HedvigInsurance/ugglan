import SwiftUI
import hCore
import hCoreUI

public struct UpdateAppScreen: View {
    @PresentableStore var store: ContractStore

    public init() {}

    public var body: some View {

        hForm {

            Image(uiImage: hCoreUIAssets.warningTriangle.image)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding([.bottom, .top], 4)

            hText(L10n.embarkUpdateAppTitle, style: .title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.bottom, 2)

            hText(L10n.embarkUpdateAppBody, style: .body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hFormAttachToBottom {

            VStack {
                hButton.LargeButtonOutlined {
                    if let url = URL(
                        string: "https://apps.apple.com/se/app/hedvig/id1303668531"
                    ) {
                        UIApplication.shared.open(url)
                    }
                    store.send(.dismissTerminationFlow)
                } content: {
                    hText(L10n.embarkUpdateAppButton, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .padding(.bottom, 4)
                hButton.LargeButtonFilled {
                    store.send(.dismissTerminationFlow)
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .padding(.bottom, 2)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

struct UpdateAppScreen_Previews: PreviewProvider {
    static var previews: some View {
        UpdateAppScreen()
    }
}
