import SwiftUI
import hCore
import hCoreUI

struct TerminationFailScreen: View {
    @PresentableStore var store: TerminationContractStore

    init() {}

    var body: some View {

        hForm {
            VStack(spacing: 8) {
                Image(uiImage: hCoreUIAssets.warningTriangle.image)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)

                hText(L10n.terminationNotSuccessfulTitle, style: .title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)

                hText(L10n.somethingWentWrong, style: .body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        .hFormAttachToBottom {

            VStack {
                hButton.LargeButtonOutlined {
                    store.send(.dismissTerminationFlow)
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                        .foregroundColor(hTextColor.primary)
                }
                .padding(.bottom, 4)
                hButton.LargeButton(type: .primary) {
                    store.send(.goToFreeTextChat)
                } content: {
                    hText(L10n.MovingUwFailure.buttonText, style: .body)
                        .foregroundColor(hTextColor.primary.inverted)
                }
                .padding(.bottom, 2)
            }
            .padding([.leading, .trailing, .bottom], 16)
        }
    }
}

struct TerminationFailScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationFailScreen()
    }
}
