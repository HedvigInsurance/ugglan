import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SelectTier: View {
    @StateObject var vm = SelectTierViewModel()
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
                    "Pick a covergare level"
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding24) {
                    VStack(spacing: .padding16) {
                        Image(uiImage: hCoreUIAssets.pillowHome.image)
                            .frame(width: 208, height: 208)

                        VStack(spacing: 0) {
                            hText(vm.insuranceDisplayName ?? "")
                            hText(vm.streetName ?? "")
                                .foregroundColor(hTextColor.Opaque.secondary)
                            hText(vm.premium?.formattedAmount ?? "" + " kr/mo")
                        }

                    }
                    .padding(.bottom, 30)

                    VStack(spacing: .padding4) {
                        DropdownView(value: vm.selectedTier.displayName, placeHolder: "Coverage level") {
                            // on tap
                            selectTierNavigationVm.isEditTierPresented = true
                        }
                        .hFieldSize(.medium)

                        hSection {
                            hButton.MediumButton(type: .secondaryAlt) {
                                // compare coverage level
                            } content: {
                                hText("Compare coverage levels", style: .body1)
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    hSection {
                        hButton.LargeButton(type: .primary) {
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
    }
}

class SelectTierViewModel: ObservableObject {
    @Inject var service: SelectTierClient
    var insuranceDisplayName: String?
    var streetName: String?
    var premium: MonetaryAmount?
    var tiers: [TierLevel] = []
    @State var selectedTier: TierLevel

    init() {
        self.selectedTier = tiers.first ?? .standard
        fetchTiers()
    }

    private func fetchTiers() {
        Task {
            let data = try await service.getTier()
            self.insuranceDisplayName = data.insuranceDisplayName
            self.streetName = data.streetName
            self.premium = data.premium
            self.tiers = data.tiers
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> SelectTierClient in SelectTierClientDemo() })
    return SelectTier()
}
