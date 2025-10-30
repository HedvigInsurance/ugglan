import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSingleItemScreen: View {
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @StateObject var vm = SubmitClaimSingleItemViewModel()

    public init() {}

    public var body: some View {
        hForm {
            hSection {
                getFields(singleItemStep: claimsNavigationVm.singleItemModel)
            }
        }
        .hFormContentPosition(.bottom)
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.claimsSingleItemDetails,
                alignment: .leading
            )
        )
        .hFormAttachToBottom {
            hSection {
                hContinueButton {
                    if let singleItemModel = claimsNavigationVm.singleItemModel {
                        Task {
                            let step = await vm.singleItemRequest(
                                context: claimsNavigationVm.currentClaimContext ?? "",
                                model: singleItemModel
                            )

                            if let step {
                                claimsNavigationVm.navigate(data: step)
                            }
                        }
                    }
                }
                .hButtonIsLoading(vm.viewState == .loading)
                .disabled(vm.viewState == .loading)
            }
        }
        .sectionContainerStyle(.transparent)
        .claimErrorTrackerForState($vm.viewState)
    }

    @ViewBuilder
    func getFields(singleItemStep: FlowClaimSingleItemStepModel?) -> some View {
        VStack(spacing: .padding4) {
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
        .accessibilitySortPriority(2)
        .padding(.vertical, .padding12)
    }

    @ViewBuilder func displayBrandAndModelField(singleItemStep: FlowClaimSingleItemStepModel?) -> some View {
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

    @ViewBuilder func displayDateField(claim: FlowClaimSingleItemStepModel?) -> some View {
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

    @ViewBuilder func displayDamageField(claim: FlowClaimSingleItemStepModel?) -> some View {
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

    @ViewBuilder func displayPurchasePriceField(claim: FlowClaimSingleItemStepModel?) -> some View {
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

@MainActor
public class SubmitClaimSingleItemViewModel: ObservableObject {
    private let service = SubmitClaimService()
    @Published var viewState: ProcessingState = .success

    @MainActor
    func singleItemRequest(context: String, model: FlowClaimSingleItemStepModel) async -> SubmitClaimStepResponse? {
        withAnimation {
            self.viewState = .loading
        }
        do {
            let data = try await service.singleItemRequest(context: context, model: model)
            withAnimation {
                self.viewState = .success
            }
            return data
        } catch let exception {
            withAnimation {
                self.viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
        return nil
    }
}

enum ClaimsFlowSingleItemFieldType: hTextFieldFocusStateCompliant {
    static var last: ClaimsFlowSingleItemFieldType {
        ClaimsFlowSingleItemFieldType.purchasePrice
    }

    var next: ClaimsFlowSingleItemFieldType? {
        switch self {
        case .purchasePrice:
            return nil
        }
    }

    case purchasePrice
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in FetchEntrypointsClientDemo() })

    return SubmitClaimSingleItemScreen()
        .environmentObject(SubmitClaimNavigationViewModel())
}
