import SwiftUI
import hCore
import hCoreUI

struct ChangeTierSummaryScreen: View {
    @ObservedObject var vm: SelectTierViewModel
    @EnvironmentObject var selectTierNavigationVm: ChangeTierNavigationViewModel
    @State var showDetails = false

    var body: some View {
        hForm {
            hSection {
                StatusCard(
                    onSelected: {

                    },
                    mainContent: ContractInformation(
                        displayName: vm.displayName,
                        exposureName: vm.exposureName
                    ),
                    title: nil,
                    subTitle: nil,
                    bottomComponent: {
                        VStack(spacing: .padding16) {
                            PriceField(
                                newPremium: vm.newPremium,
                                currentPremium: vm.currentPremium
                            )

                            if showDetails {
                                detailsView
                            }

                            hButton.MediumButton(
                                type: .secondary
                            ) {
                                if showDetails {
                                    showDetails = false
                                } else {
                                    showDetails = true
                                }
                            } content: {
                                withAnimation {
                                    hText(showDetails ? "Hide details" : L10n.ClaimStatus.ClaimDetails.button)
                                }
                            }
                        }
                    }
                )
                .hCardWithoutSpacing
            }
            .sectionContainerStyle(.transparent)
        }
    }

    var detailsView: some View {
        VStack(spacing: .padding16) {
            hRowDivider()
                .hWithoutDividerPadding
            VStack(alignment: .leading, spacing: 0) {
                hText("Details")
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(vm.selectedTier?.displayItems ?? []) { tier in
                    rowItem(for: tier)
                }
            }
        }
    }

    func rowItem(for displayItem: Tier.TierDisplayItem) -> some View {
        HStack {
            hText(displayItem.title)
            Spacer()
            hText(displayItem.value)
        }
        .foregroundColor(hTextColor.Opaque.secondary)
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> SelectTierClient in SelectTierClientDemo() })
    return ChangeTierSummaryScreen(vm: .init())
}
