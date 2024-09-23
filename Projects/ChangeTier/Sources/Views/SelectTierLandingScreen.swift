import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SelectTierLandingScreen: View {
    @ObservedObject var vm: SelectTierViewModel
    @EnvironmentObject var selectTierNavigationVm: SelectTierNavigationViewModel

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
                    if vm.canEditTier {
                        hSection {
                            hFloatingField(value: "Max", placeholder: L10n.tierFlowCoverageLabel) {
                                selectTierNavigationVm.isTierLockedInfoViewPresented = true
                            }
                            .hFieldLockedState
                            .hFieldTrailingView {
                                Image(uiImage: hCoreUIAssets.lock.image)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                    } else {
                        DropdownView(value: vm.selectedTier?.name ?? "", placeHolder: L10n.tierFlowCoverageLabel) {
                            selectTierNavigationVm.isEditTierPresented = true
                        }
                    }
                    DropdownView(
                        value: vm.selectedDeductible?.deductibleAmount?.formattedAmount ?? "",
                        placeHolder: L10n.tierFlowDeductibleLabel
                    ) {
                        selectTierNavigationVm.isEditDeductiblePresented = true
                    }
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
                                hText(newPremium.formattedAmount + "/mo")
                            } else {
                                hText(vm.currentPremium?.formattedAmount ?? "" + "/mo")
                            }

                            if vm.newPremium != vm.currentPremium {
                                hText(
                                    L10n.tierFlowPreviousPrice + " " + (vm.currentPremium?.formattedAmount ?? "")
                                        + "/mo",
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
    var displayName: String?
    var exposureName: String?
    var tiers: [Tier] = []

    var currentPremium: MonetaryAmount?
    var currentTier: Tier?
    var currentDeductible: Deductible?
    var newPremium: MonetaryAmount?
    /* TODO: FETCH supportsChangeTier FROM CURRENT AGREEMENT */
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
    func setTier(for tierId: String) {
        withAnimation {
            let newSelectedTier = tiers.first(where: { $0.id == tierId })
            if newSelectedTier != selectedTier {
                self.selectedDeductible = nil
            }
            self.selectedTier = newSelectedTier
        }
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        withAnimation {
            self.selectedDeductible = selectedTier?.deductibles.first(where: { $0.id == deductibleId })
        }
    }

    private func fetchTiers() {
        Task { @MainActor in
            let data = try await service.getTier()
            self.tiers = data.tiers
            self.displayName = data.tiers.first?.productVariant.displayName
            self.exposureName = data.tiers.first?.exposureName
            self.currentPremium = data.currentPremium

            /* TODO: IMPLEMENT **/
            self.newPremium = .init(amount: "549", currency: "SEK")
            self.currentTier = .init(
                id: "id",
                name: "Max",
                level: 3,
                deductibles: [],
                premium: .init(amount: "", currency: ""),
                displayItems: [],
                exposureName: "",
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
                    partner: "",
                    perils: [],
                    insurableLimits: [],
                    documents: [],
                    displayName: "",
                    displayNameTier: "",
                    displayNameTierLong: ""
                )
            )
            self.currentDeductible = .init(
                id: "id",
                deductibleAmount: .init(amount: "449", currency: "SEK"),
                deductiblePercentage: 25
            )
            self.canEditTier = false
            self.selectedTier = currentTier
            self.selectedDeductible = currentDeductible
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> SelectTierClient in SelectTierClientDemo() })
    return SelectTierLandingScreen(vm: .init())
}
