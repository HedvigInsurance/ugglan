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
                    "Customize your insurance",
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .body2,
                    "Select your coverage level and deductible"
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
                    if vm.alreadyHasHighestTier {
                        hSection {
                            hFloatingField(value: "Max", placeholder: "Coverage level") {
                                /* TODO: OPEN INFO THINGY */
                            }
                            .hFieldLockedState
                            .hFieldTrailingView {
                                Image(uiImage: hCoreUIAssets.lock.image)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                    } else {
                        DropdownView(value: vm.selectedTier?.name ?? "", placeHolder: "Select coverage level") {
                            selectTierNavigationVm.isEditTierPresented = true
                        }
                    }
                    DropdownView(
                        value: vm.selectedDeductible?.deductibleAmount?.formattedAmount ?? "",
                        placeHolder: "Select deductible level"
                    ) {
                        selectTierNavigationVm.isEditDeductiblePresented = true
                    }
                }
                .hFieldSize(.small)
                .hWithTransparentColor
                .hWithoutHorizontalPadding

                hRow {
                    HStack(alignment: .top) {
                        hText("Total")
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            if vm.isValid {
                                hText(vm.newPremium?.formattedAmount ?? "" + " kr/mo")
                            } else {
                                hText("- kr/mo")
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }

                            if vm.isValid {
                                hText(
                                    "Current price " + (vm.currentPremium?.formattedAmount ?? "") + " kr/mo",
                                    style: .label
                                )
                                .foregroundColor(hTextColor.Opaque.secondary)
                            } else {
                                hText(
                                    "Previous price " + (vm.currentPremium?.formattedAmount ?? "") + " kr/mo",
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
                    hText("Compare coverage levels", style: .body1)
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
    //    var deductibles: [Deductible] = []
    var tierLevel: Int = 0
    @Published var selectedTier: Tier?
    @Published var selectedDeductible: Deductible?
    var currentPremium: MonetaryAmount?
    var newPremium: MonetaryAmount?

    var isValid: Bool {
        return selectedTier != nil && selectedDeductible != nil
    }

    init() {
        fetchTiers()
    }

    var alreadyHasHighestTier: Bool {
        /* TODO: IMPLEMENT */
        return false
    }

    func setTier(for tierId: String) {
        Task {
            let data = try await service.getTier()
            self.selectedTier = data.tiers.first(where: { $0.id == tierId })
        }
    }

    func setDeductible(for deductibleId: String) {
        Task {
            let data = try await service.getTier()
            self.selectedDeductible = selectedTier?.deductibles.first(where: { $0.id == deductibleId })
        }
    }

    private func fetchTiers() {
        Task {
            let data = try await service.getTier()
            self.displayName = data.tiers.first?.productVariant.displayName
            self.exposureName = data.tiers.first?.exposureName
            self.currentPremium = data.currentPremium
            self.newPremium = .init(amount: "", currency: "") /* TODO: IMPLEMENT **/
            self.tiers = data.tiers
            //            self.deductibles = [] /* TODO: IMPLEMENT **/
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> SelectTierClient in SelectTierClientDemo() })
    return SelectTierLandingScreen(vm: .init())
}
