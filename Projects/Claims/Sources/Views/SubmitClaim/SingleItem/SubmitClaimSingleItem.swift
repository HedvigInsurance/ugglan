import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimSingleItem: View {
    @PresentableStore var store: SubmitClaimStore
    @State var type: ClaimsFlowSingleItemFieldType?
    
    public init() {}
    
    public var body: some View {
        hForm {
        }
        .hFormTitle(.small, .title1, L10n.claimsSingleItemDetails)
        .hFormAttachToBottom {
            VStack(spacing: 4) {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.singleItemStep
                    }
                ) { singleItemStep in
                    hSection {
                        getFields(singleItemStep: singleItemStep)
                            .disableOn(SubmitClaimStore.self, [.postSingleItem])
                        
                        LoadingButtonWithContent(SubmitClaimStore.self, .postSingleItem) {
                            store.send(.singleItemRequest(purchasePrice: singleItemStep?.purchasePrice))
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
    }
    
    @ViewBuilder
    func getFields(singleItemStep: FlowClamSingleItemStepModel?) -> some View {
        VStack(spacing: 4) {
            displayBrandAndModelField(singleItemStep: singleItemStep)
            displayDateField(claim: singleItemStep)
            displayPurchasePriceField(claim: singleItemStep)
            displayDamageField(claim: singleItemStep)
        }
        InfoCard(text: L10n.claimsSingleItemNoticeLabel, type: .info)
            .padding(.vertical, 12)
    }

@ViewBuilder func displayBrandAndModelField(singleItemStep: FlowClamSingleItemStepModel?) -> some View {
    if (singleItemStep?.availableItemModelOptions.count) ?? 0 > 0
        || (singleItemStep?.availableItemBrandOptions.count) ?? 0 > 0
    {
        //            hSection {
        hFloatingField(
            value: singleItemStep?.getBrandOrModelName() ?? "",
            placeholder: L10n.singleItemInfoBrand,
            onTap: {
                store.send(.navigationAction(action: .openBrandPicker))
            }
        )
        //            }
        //            .sectionContainerStyle(.transparent)
    }
}

@ViewBuilder func displayDateField(claim: FlowClamSingleItemStepModel?) -> some View {
    //        hSection {
    hDatePickerField(
        config: .init(
            maxDate: Date(),
            placeholder: L10n.Claims.Item.Screen.Date.Of.Purchase.button,
            title: L10n.Claims.Item.Screen.Date.Of.Purchase.button
        ),
        selectedDate: claim?.purchaseDate?.localDateToDate
    ) { date in
        store.send(.setSingleItemPurchaseDate(purchaseDate: date))
    }
    //        }
    //        .sectionContainerStyle(.transparent)
}

@ViewBuilder func displayDamageField(claim: FlowClamSingleItemStepModel?) -> some View {
    if !(claim?.availableItemProblems.isEmpty ?? true) {
        //            hSection {
        hFloatingField(
            value: claim?.getChoosenDamagesAsText() ?? "",
            placeholder: L10n.Claims.Item.Screen.Damage.button,
            onTap: {
                store.send(.navigationAction(action: .openDamagePickerScreen))
            }
        )
        //            }
        //            .sectionContainerStyle(.transparent)
    }
}

@ViewBuilder func displayPurchasePriceField(claim: FlowClamSingleItemStepModel?) -> some View {
    
    //        hSection {
    hFloatingField(
        value: (claim?.purchasePrice != nil)
        ? String(format: "%.0f", claim?.purchasePrice ?? 0) + " " + (claim?.prefferedCurrency ?? "") : "",
        placeholder: L10n.Claims.Item.Screen.Purchase.Price.button,
        onTap: {
            store.send(.navigationAction(action: .openPriceInput))
        }
    )
    //        }
    //        .sectionContainerStyle(.transparent)
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
