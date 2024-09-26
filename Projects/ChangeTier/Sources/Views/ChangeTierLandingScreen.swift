import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeTierLandingScreen: View {
    @ObservedObject var vm: SelectTierViewModel
    @EnvironmentObject var selectTierNavigationVm: ChangeTierNavigationViewModel
    var contractId: String

    init(
        vm: SelectTierViewModel,
        contractId: String
    ) {
        self.vm = vm
        self.contractId = contractId
        vm.contractId = contractId
    }

    var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .body2,
                    L10n.tierFlowTitle,
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .body2,
                    L10n.tierFlowSubtitle
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding4) {
                    informationCard
                    buttons
                        .padding(.bottom, 16)
                }
            }
    }

    private var informationCard: some View {
        hSection {
            VStack(spacing: 0) {
                hRow {
                    HStack(spacing: .padding12) {
                        Image(uiImage: hCoreUIAssets.pillowHome.image)
                            .resizable()
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 0) {
                            hText(vm.displayName ?? "")
                            hText(vm.exposureName ?? "")
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                VStack(spacing: .padding4) {
                    if !vm.canEditTier {
                        hSection {
                            hFloatingField(value: vm.selectedTier?.name ?? "", placeholder: L10n.tierFlowCoverageLabel)
                            {
                                selectTierNavigationVm.isTierLockedInfoViewPresented = true
                            }
                            .hFieldLockedState
                            .hFieldTrailingView {
                                Image(uiImage: hCoreUIAssets.lock.image)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                    } else {
                        DropdownView(value: vm.selectedTier?.name ?? "", placeHolder: L10n.tierFlowCoveragePlaceholder)
                        {
                            selectTierNavigationVm.isEditTierPresented = true
                        }
                    }

                    DropdownView(
                        value: vm.selectedDeductible?.deductibleAmount?.formattedAmount ?? "",
                        placeHolder: L10n.tierFlowDeductiblePlaceholder
                    ) {
                        selectTierNavigationVm.isEditDeductiblePresented = true
                    }
                    .disabled(vm.selectedTier == nil)
                }
                .hFieldSize(.small)
                .hWithTransparentColor
                .hWithoutHorizontalPadding

                hRow {
                    HStack(alignment: .top) {
                        hText(L10n.tierFlowTotal)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            if let newPremium = vm.newPremium {
                                hText(newPremium.formattedAmountPerMonth)
                            } else {
                                hText(vm.currentPremium?.formattedAmountPerMonth ?? "")
                            }

                            if vm.newPremium != vm.currentPremium {
                                hText(
                                    L10n.tierFlowPreviousPrice(vm.currentPremium?.formattedAmountPerMonth ?? ""),
                                    style: .label
                                )
                                .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var buttons: some View {
        hSection {
            VStack(spacing: .padding8) {
                hButton.LargeButton(type: .ghost) {
                    selectTierNavigationVm.isCompareTiersPresented = true
                } content: {
                    hText(L10n.tierFlowCompareButton, style: .body1)
                }
                hButton.LargeButton(type: .primary) {
                    /** TODO: ADD ACTION **/
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .disabled(!vm.isValid)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

public class SelectTierViewModel: ObservableObject {
    @Inject var service: SelectTierClient
    @Published var displayName: String?
    var exposureName: String?
    var tiers: [Tier] = []
    @Published var contractId: String?

    var currentPremium: MonetaryAmount?
    var currentTier: Tier?
    var currentDeductible: Deductible?
    var newPremium: MonetaryAmount?
    var canEditTier: Bool = false

    @Published var selectedTier: Tier?
    @Published var selectedDeductible: Deductible?

    var isValid: Bool {
        let selectedTierIsSameAsCurrent = currentTier?.name == selectedTier?.name
        let selectedDeductibleIsSameAsCurrent = currentDeductible == selectedDeductible
        let hasSelectedValues = selectedTier != nil && selectedDeductible != nil

        return hasSelectedValues && !(selectedTierIsSameAsCurrent && selectedDeductibleIsSameAsCurrent)
    }

    init() {
        fetchTiers()
    }

    @MainActor
    func setTier(for tierName: String) {
        withAnimation {
            let newSelectedTier = tiers.first(where: { $0.name == tierName })
            if newSelectedTier != selectedTier {
                self.selectedDeductible = nil
            }
            self.selectedTier = newSelectedTier
        }
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        withAnimation {
            if let deductible = selectedTier?.deductibles.first(where: { $0.id == deductibleId }) {
                self.selectedDeductible = deductible
            }
        }
    }

    private func fetchTiers() {
        Task { @MainActor in
            let data = try await service.getTier(contractId: contractId ?? "")
            self.tiers = data.tiers
            self.displayName = data.tiers.first?.productVariant.displayName
            self.exposureName = data.tiers.first?.exposureName
            self.currentPremium = data.currentPremium

            self.currentTier = data.currentTier
            self.currentDeductible = data.currentDeductible
            self.canEditTier = data.canEditTier

            self.selectedTier = currentTier
            self.selectedDeductible = currentDeductible
            self.newPremium = selectedTier?.premium
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> SelectTierClient in ChangeTierClientDemo() })
    return ChangeTierLandingScreen(vm: .init(), contractId: "contractId")
}
