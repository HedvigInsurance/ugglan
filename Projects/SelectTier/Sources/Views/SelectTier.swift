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
                        selectTierNavigationVm.isEditTierPresented = vm.selectedTier ?? TierLevel.none
                    }
                    DropdownView(value: "", placeHolder: "Select deductible level") {
                        // on tap
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
                            hText("- kr/mo")
                            hText("Current price 279 kr/mo", style: .label)
                        }
                        .foregroundColor(hTextColor.Opaque.secondary)
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
                .disabled(vm.selectedTier == nil)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

public class SelectTierViewModel: ObservableObject {
    @Inject var service: SelectTierClient
    var insuranceDisplayName: String?
    var streetName: String?
    var premium: MonetaryAmount?
    var tiers: [TierLevel] = []
    @State var selectedTier: TierLevel?

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
