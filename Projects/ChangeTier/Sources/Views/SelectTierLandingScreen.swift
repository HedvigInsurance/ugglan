import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SelectTierLandingScreen: View {
    @ObservedObject var vm: SelectTierViewModel
    @EnvironmentObject var selectTierNavigationVm: ChangeTierNavigationViewModel
    @EnvironmentObject var router: Router

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
                    ContractInformation(
                        displayName: vm.displayName,
                        exposureName: vm.exposureName
                    )
                }

                VStack(spacing: .padding4) {
                    if vm.canEditTier {
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
                    PriceField(
                        newPremium: vm.newPremium,
                        currentPremium: vm.currentPremium
                    )
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
                    router.push(ChangeTierRouterActions.summary)
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
                deductibles: [
                    .init(
                        id: "id",
                        deductibleAmount: .init(amount: "1000", currency: "SEK"),
                        deductiblePercentage: 0,
                        subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                        premium: .init(amount: "1167", currency: "SEK")
                    ),
                    .init(
                        id: "id2",
                        deductibleAmount: .init(amount: "2000", currency: "SEK"),
                        deductiblePercentage: 25,
                        subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                        premium: .init(amount: "999", currency: "SEK")
                    ),
                    .init(
                        id: "id3",
                        deductibleAmount: .init(amount: "3000", currency: "SEK"),
                        deductiblePercentage: 15,
                        subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                        premium: .init(amount: "569", currency: "SEK")
                    ),
                ],
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
                deductiblePercentage: 25,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "999", currency: "SEK")
            )
            /* TODO: FETCH supportsChangeTier FROM CURRENT AGREEMENT */
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
