import SwiftUI
import hCore
import hCoreUI

struct MovingFlowFailure: View {
    @PresentableStore var store: ContractStore
    var body: some View {
        hFormNew {
            Image(uiImage: hCoreUIAssets.warningTriangle.image)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(hTintColorNew.amber600)
                .padding(.top, 220)

            hText(
                "Tyvärr kan vi inte ändra din adress just nu. Skriv till oss i chatten så hjälper vi dig vidare.",
                style: .title2
            )
            .padding([.leading, .trailing], 16)
        }
        .hFormAttachToBottomNew {
            VStack {
                hButton.LargeButtonFilled {
                    store.send(.goToFreeTextChat)
                } content: {
                    hText(L10n.openChat)
                }
                .padding([.leading, .trailing], 16)

                hButton.LargeButtonText {
                    store.send(.navigationActionMovingFlow(action: .dismissMovingFlow))
                } content: {
                    hText(L10n.generalCancelButton)
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }
}

struct MovingFlowFailure_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowFailure()
    }
}
