import SwiftUI
import hCore
import hCoreUI

struct PriceInputScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var purchasePrice: String = ""
    @State var type: ClaimsFlowSingleItemFieldType? = .purchasePrice
    var onSave: (String) -> Void

    init(
        onSave: @escaping (String) -> Void
    ) {
        self.onSave = onSave
    }

    var body: some View {
        hForm {}
            .hUseNewStyle
            .hFormAttachToBottom {
                VStack(spacing: 16) {
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
                    }
                    hSection {
                        VStack(spacing: 8) {
                            hButton.LargeButtonFilled {
                                UIApplication.dismissKeyboard()
                                onSave(purchasePrice)
                            } content: {
                                hTextNew(L10n.generalSaveButton, style: .body)
                            }
                            hButton.LargeButtonText {
                                UIApplication.dismissKeyboard()
                                store.send(.navigationAction(action: .dismissScreen))
                            } content: {
                                hTextNew(L10n.generalNotSure, style: .body)
                            }
                        }
                    }
                }
            }
            .introspectScrollView { scrollView in
                scrollView.keyboardDismissMode = .interactive
            }
    }
}
