import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SelectTierLandingScreen: View {
    var vm: SelectTierViewModel
    @EnvironmentObject var selectTierNavigationVm: SelectTierNavigationViewModel

    init(
        vm: SelectTierViewModel
    ) {
        self.vm = vm
    }

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
                            hText(vm.insuranceDisplayName ?? "")
                            hText(vm.streetName ?? "")
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                VStack(spacing: .padding4) {
                    DropdownView(value: vm.selectedTier?.title ?? "", placeHolder: "Select coverage level") {
                        selectTierNavigationVm.isEditTierPresented = true
                    }
                    DropdownView(value: vm.selectedDeductible?.title ?? "", placeHolder: "Select deductible level") {
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
                    // compare coverage level
                } content: {
                    hText("Compare coverage levels", style: .body1)
                }
                /* TODO: DISABLE IF NO TIER SELECTED */
                hButton.LargeButton(type: .primary) {
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
    var insuranceDisplayName: String?
    var streetName: String?
    var tiers: [Tier] = []
    var deductibles: [Deductible] = []
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

    func setTier(for tierId: String) {
        Task {
            let data = try await service.getTier()
            self.selectedTier = data.tiers.first(where: { $0.id == tierId })
        }
    }

    func setDeductible(for deductibleId: String) {
        Task {
            let data = try await service.getTier()
            self.selectedDeductible = data.deductibles.first(where: { $0.id == deductibleId })
        }
    }

    private func fetchTiers() {
        Task {
            let data = try await service.getTier()
            self.insuranceDisplayName = data.insuranceDisplayName
            self.streetName = data.streetName
            self.currentPremium = data.currentPremium
            self.newPremium = data.newPremium
            self.tiers = data.tiers
            self.deductibles = data.deductibles
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> SelectTierClient in SelectTierClientDemo() })
    return SelectTierLandingScreen(vm: .init())
}
