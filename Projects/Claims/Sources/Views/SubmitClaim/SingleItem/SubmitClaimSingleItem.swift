import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimSingleItem: View {
    @PresentableStore var store: SubmitClaimStore
    @State var type: ClaimsFlowSingleItemFieldType?
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel

    public init() {}

    public var body: some View {
        hForm {
        }
        .hFormTitle(title: .init(.small, .title1, L10n.claimsSingleItemDetails))
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
                        hButton.LargeButton(type: .primary) {
                            store.send(.singleItemRequest(purchasePrice: singleItemStep?.purchasePrice))
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                        .trackLoading(SubmitClaimStore.self, action: .postSingleItem)
                        .presentableStoreLensAnimation(.default)
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
        .claimErrorTrackerFor([.postSingleItem])
    }

    @ViewBuilder
    func getFields(singleItemStep: FlowClamSingleItemStepModel?) -> some View {
        VStack(spacing: 4) {
            displayBrandAndModelField(singleItemStep: singleItemStep)
            displayDateField(claim: singleItemStep)
            if let singleItemStep, singleItemStep.purchasePriceApplicable {
                displayPurchasePriceField(claim: singleItemStep)
            }
            displayDamageField(claim: singleItemStep)
        }
        InfoCard(
            text: (singleItemStep?.purchasePriceApplicable ?? false)
                ? L10n.claimsSingleItemNoticeLabel : L10n.claimsSingleItemNoticeWithoutPriceLabel,
            type: .info
        )
        .padding(.vertical, .padding12)
    }

    @ViewBuilder func displayBrandAndModelField(singleItemStep: FlowClamSingleItemStepModel?) -> some View {
        if (singleItemStep?.availableItemModelOptions.count) ?? 0 > 0
            || (singleItemStep?.availableItemBrandOptions.count) ?? 0 > 0
        {
            hFloatingField(
                value: singleItemStep?.getBrandOrModelName() ?? "",
                placeholder: L10n.singleItemInfoBrand,
                onTap: {
                    claimsNavigationVm.isBrandPickerPresented = true
                }
            )
        }
    }

    @ViewBuilder func displayDateField(claim: FlowClamSingleItemStepModel?) -> some View {
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
    }

    @ViewBuilder func displayDamageField(claim: FlowClamSingleItemStepModel?) -> some View {
        if !(claim?.availableItemProblems.isEmpty ?? true) {
            hFloatingField(
                value: claim?.getChoosenDamagesAsText() ?? "",
                placeholder: L10n.Claims.Item.Screen.Damage.button,
                onTap: {
                    claimsNavigationVm.isDamagePickerPresented = true
                }
            )
        }
    }

    @ViewBuilder func displayPurchasePriceField(claim: FlowClamSingleItemStepModel?) -> some View {
        hFloatingField(
            value: (claim?.purchasePrice != nil)
                ? String(format: "%.0f", claim?.purchasePrice ?? 0) + " " + (claim?.prefferedCurrency ?? "") : "",
            placeholder: L10n.Claims.Item.Screen.Purchase.Price.button,
            onTap: {
                claimsNavigationVm.isPriceInputPresented = true
            }
        )
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
