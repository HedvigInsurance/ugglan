import SwiftUI
import hCore
import hCoreUI

struct CoInsuredErrorScreen: View {
    @PresentableStore var store: ContractStore

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.infoIcon.image)
                    .foregroundColor(hSignalColor.blueElement)
                VStack {
                    hText(L10n.somethingWentWrong)
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText(L10n.coinsuredErrorText)
                        .foregroundColor(hTextColor.secondaryTranslucent)
                }
                hButton.MediumButton(type: .primary) {
                    store.send(.goToFreeTextChat)
                } content: {
                    hText(L10n.openChat)
                }
            }
            .padding(.horizontal, 16)
        }
        .hFormAttachToBottom {
            hButton.LargeButton(type: .ghost) {
                store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
            } content: {
                hText(L10n.generalCancelButton)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct CoInsuredErrorScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredErrorScreen()
    }
}
