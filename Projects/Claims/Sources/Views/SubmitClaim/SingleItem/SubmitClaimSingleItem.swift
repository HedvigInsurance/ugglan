import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimSingleItem: View {
    @State var type: ClaimsFlowSingleItemFieldType?
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    @StateObject var vm = SubmitClaimSingleItemViewModel()

    public init() {}

    public var body: some View {
        hForm {
        }
        .hFormTitle(title: .init(.small, .displayXSLong, L10n.claimsSingleItemDetails))
        .hFormAttachToBottom {
            hSection {
                getFields(singleItemStep: claimsNavigationVm.singleItemModel)
                hButton.LargeButton(type: .primary) {
                    let singleItemModel = claimsNavigationVm.singleItemModel
                    Task {
                        let step = await vm.singleItemRequest(
                            context: claimsNavigationVm.currentClaimContext ?? "",
                            model: singleItemModel
                        )

                        if let step {
                            claimsNavigationVm.navigate(data: step)
                        }
                    }
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .presentableStoreLensAnimation(.default)
            }
            .sectionContainerStyle(.transparent)
        }
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
            claimsNavigationVm.singleItemModel?.purchaseDate = date.localDateString
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

public class SubmitClaimSingleItemViewModel: ObservableObject {
    @Inject private var service: SubmitClaimClient

    @MainActor
    func singleItemRequest(context: String, model: FlowClamSingleItemStepModel?) async -> SubmitClaimStepResponse? {
        //        setProgress(to: 0)

        //        withAnimation {
        //            self.viewState = .loading
        //        }

        do {
            let data = try await service.singleItemRequest(context: context, model: model)

            //            withAnimation {
            //                self.viewState = .success
            //            }

            return data
        } catch let exception {
            //            withAnimation {
            //                self.viewState = .error(errorMessage: exception.localizedDescription)
            //            }
        }
        return nil
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
