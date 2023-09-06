import SwiftUI
import hCore
import hCoreUI

struct MovingFlowFailure: View {
    @PresentableStore var store: MoveFlowStore
    var body: some View {
        hForm {
            Image(uiImage: hCoreUIAssets.warningTriangle.image)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(hAmberColorNew.amber600)
                .padding(.top, 270)

            hText(
                L10n.changeAddressErrorMessage,
                style: .body
            )
            .multilineTextAlignment(.center)
            .padding([.leading, .trailing], 16)
        }
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonPrimary {
                    store.send(.navigation(action: .goToFreeTextChat))
                } content: {
                    hText(L10n.openChat, style: .body)
                }
                .padding([.leading, .trailing], 16)

                hButton.LargeButtonText {
                    store.send(.navigation(action: .dismissMovingFlow))
                } content: {
                    hText(L10n.generalCancelButton, style: .body)
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
