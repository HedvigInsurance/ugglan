import Addons
import AppStateContainer
import Contracts
import CrossSell
import SwiftUI
import hCore
import hCoreUI

struct HomeAddonsSection: View {
    let addonBanners: [AddonBanner]
    @AppObservedObject private var contractStore: ContractStore
    @EnvironmentObject private var navigationVm: HomeNavigationViewModel

    var body: some View {
        if !addonBanners.isEmpty {
            hSection {
                VStack(spacing: .padding8) {
                    ForEach(addonBanners, id: \.self) { banner in
                        let contractInfos = contractStore.getAddonContractInfosFor(contractIds: banner.contractIds)
                        let input = ChangeAddonInput(addonSource: .crossSell, contractInfos: contractInfos)
                        CrossSellRow(
                            title: banner.displayTitle,
                            subtitle: banner.displayDescription,
                            buttonTitle: L10n.homeAddonsReadMoreButton,
                            variant: .secondary,
                            isLoading: navigationVm.isAddonPresented?.contractInfos == input.contractInfos,
                            pillow: { AddonPillowView(type: banner.addonType) }
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) { navigationVm.isAddonPresented = input }
                        }
                    }
                }
            }
            .withHeader(title: L10n.insuranceAddonsSubheading)
            .sectionContainerStyle(.transparent)
        }
    }
}

#Preview {
    HomeAddonsSection(
        addonBanners: [
            .init(
                contractIds: [],
                displayTitle: "Travel Insurance Plus",
                displayDescription: "Extended travel insurance with extra coverage for your travels",
                badges: ["Popular"],
                addonType: .travelPlus
            )
        ]
    )
    .environmentObject(HomeNavigationViewModel())
}
