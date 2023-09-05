import Presentation
import SwiftUI
import hCore
import hCoreUI

struct PriceInputScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var purchasePrice: String = ""
    @State var type: ClaimsFlowSingleItemFieldType? = .purchasePrice
    let currency: String
    var onSave: (String) -> Void

    init(
        onSave: @escaping (String) -> Void
    ) {
        self.onSave = onSave
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        currency = store.state.singleItemStep?.prefferedCurrency ?? ""
        if let purchasePrice = store.state.singleItemStep?.purchasePrice {
            self.purchasePrice = String(purchasePrice)
        }
    }

    var body: some View {
        hForm {
            hSection {
                hFloatingTextField(
                    masking: Masking(type: .digits),
                    value: $purchasePrice,
                    equals: $type,
                    focusValue: .purchasePrice,
                    placeholder: L10n.Claims.Item.Screen.Purchase.Price.button,
                    suffix: currency
                )
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButtonPrimary {
                        UIApplication.dismissKeyboard()
                        onSave(purchasePrice)
                    } content: {
                        hText(L10n.generalSaveButton, style: .body)
                    }
                    hButton.LargeButtonText {
                        UIApplication.dismissKeyboard()
                        store.send(.navigationAction(action: .dismissScreen))
                    } content: {
                        hText(L10n.generalNotSure, style: .body)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .introspectScrollView { scrollView in
            scrollView.keyboardDismissMode = .interactive
        }
    }
}
