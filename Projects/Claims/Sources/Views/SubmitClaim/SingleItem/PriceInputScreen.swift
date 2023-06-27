import SwiftUI
import hCore
import hCoreUI

struct PriceInputScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var purchasePrice: String = ""
    @State var type: ClaimsFlowSingleItemFieldType?

    var body: some View {

        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in

            hSection {
                hFloatingTextField(
                    masking: Masking(type: .digits),
                    value: $purchasePrice,
                    equals: $type,
                    focusValue: .purchasePrice,
                    placeholder: L10n.Claims.Item.Screen.Purchase.Price.button,
                    suffix: singleItemStep?.prefferedCurrency ?? ""
                )
            }
            .sectionContainerStyle(.transparent)
        }

        VStack(spacing: 8) {
            hButton.LargeButtonFilled {
                store.send(.navigationAction(action: .dismissScreen))
            } content: {
                hTextNew(L10n.generalSaveButton, style: .body)
            }
            hButton.LargeButtonText {
                store.send(.navigationAction(action: .dismissScreen))
            } content: {
                hTextNew(L10n.generalNotSure, style: .body)
            }
        }
        .padding(.horizontal, 16)
    }
}
