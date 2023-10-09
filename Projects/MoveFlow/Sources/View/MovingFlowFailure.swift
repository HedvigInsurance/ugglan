import SwiftUI
import hCore
import hCoreUI

struct MovingFlowFailure: View {
    @PresentableStore var store: MoveFlowStore
    let error: String
    var body: some View {
        hForm {
            RetryView(title: nil, subtitle: error)
        }
        .hDisableScroll
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButton(type: .primary) {
                    //                    store.send(.navigation(action: .dismissMovingFlow))
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    store.send(.navigation(action: .goToFreeTextChat))
                    //                    }
                } content: {
                    hText(L10n.openChat, style: .body)
                }
                .padding([.horizontal], 16)

                hButton.LargeButton(type: .ghost) {
                    store.send(.navigation(action: .dismissMovingFlow))
                } content: {
                    hText(L10n.generalCancelButton, style: .body)
                }
                .padding([.horizontal], 16)
            }
        }
    }
}

struct MovingFlowFailure_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .sv_SE
        return MovingFlowFailure(error: "error")
    }
}
