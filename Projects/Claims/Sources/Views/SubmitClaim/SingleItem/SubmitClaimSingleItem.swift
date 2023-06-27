import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimSingleItem: View {
    @PresentableStore var store: SubmitClaimStore
    @State var purchasePrice: String = ""
    @State var validPriceInput = false
    @State var type: ClaimsFlowSingleItemFieldType?

    public init() {}

    public var body: some View {
        hForm {
        }
        .hUseNewStyle
        .hFormTitle(.small, .customTitle, L10n.claimsSingleItemDetails)
        .hFormAttachToBottom {
            VStack(spacing: 4) {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.singleItemStep
                    }
                ) { singleItemStep in
                    displayBrandAndModelField(singleItemStep: singleItemStep)
                    displayDateField(claim: singleItemStep)
                    displayPurchasePriceField(claim: singleItemStep)
                    displayDamageField(claim: singleItemStep)
                    InfoCard(text: L10n.claimsSingleItemNoticeLabel)
                        .padding(.vertical, 12)
                }
                LoadingButtonWithContent(.postSingleItem) {
                    store.send(.singleItemRequest(purchasePrice: Double(purchasePrice)))
                    UIApplication.dismissKeyboard()
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder func displayBrandAndModelField(singleItemStep: FlowClamSingleItemStepModel?) -> some View {
        if (singleItemStep?.availableItemModelOptions.count) ?? 0 > 0
            || (singleItemStep?.availableItemBrandOptions.count) ?? 0 > 0
        {
            hSection {
                hFloatingField(
                    value: singleItemStep?.getBrandOrModelName() ?? "",
                    placeholder: L10n.singleItemInfoBrand,
                    onTap: {
                        store.send(.navigationAction(action: .openBrandPicker))
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder func displayDateField(claim: FlowClamSingleItemStepModel?) -> some View {

        hSection {
            hFloatingField(
                value: claim?.purchaseDate ?? "",
                placeholder: L10n.Claims.Item.Screen.Date.Of.Purchase.button,
                onTap: {
                    store.send(.navigationAction(action: .openDatePicker(type: .setDateOfPurchase)))
                }
            )
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder func displayDamageField(claim: FlowClamSingleItemStepModel?) -> some View {
        if !(claim?.availableItemProblems.isEmpty ?? true) {
            hSection {
                hFloatingField(
                    value: claim?.getChoosenDamagesAsText() ?? "",
                    placeholder: L10n.Claims.Item.Screen.Damage.button,
                    onTap: {
                        store.send(.navigationAction(action: .openDamagePickerScreen))
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder func displayPurchasePriceField(claim: FlowClamSingleItemStepModel?) -> some View {

        hSection {
            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $purchasePrice,
                equals: $type,
                focusValue: .purchasePrice,
                placeholder: L10n.Claims.Item.Screen.Purchase.Price.button,
                suffix: claim?.prefferedCurrency ?? ""
            )
        }
        .sectionContainerStyle(.transparent)
    }
}

enum ClaimsFlowSingleItemFieldType: hTextFieldFocusStateCompliant {
    static var last: ClaimsFlowSingleItemFieldType {
        return ClaimsFlowSingleItemFieldType.purchasePrice
    }

    var next: ClaimsFlowSingleItemFieldType? {
        switch self {
        case .purchasePrice:
            return nil
        }
    }

    case purchasePrice
}

struct SubmitClaimSingleItem_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSingleItem()
    }
}
