import SwiftUI
import hCore
import hCoreUI

@MainActor
public class RemoveAddonViewModel: ObservableObject {
    let addonService = AddonsService()
    let contractInfo: AddonConfig
    @Published var fetchState: ProcessingState = .loading
    @Published var submittingState: ProcessingState = .loading
    @Published var removeOffer: AddonRemoveOffer?
    @Published var selectedAddons: Set<ActiveAddon> = []
    @Published var addonRemoveOfferCost: ItemCost?
    @Published var fetchingCostState: ProcessingState = .success

    init(_ contractInfo: AddonConfig, _ preselectedAddons: Set<String>) {
        self.contractInfo = contractInfo
        Task { [weak self] in
            await self?.fetchOffer()
            guard let offer = self?.removeOffer else { return }
            self?.selectedAddons = Set(
                offer.removableAddons.filter { preselectedAddons.contains($0.displayTitle) }
            )
        }
    }

    var allowToContinue: Bool {
        !selectedAddons.isEmpty
    }

    func toggleAddon(_ addon: ActiveAddon) {
        if selectedAddons.contains(addon) {
            selectedAddons.remove(addon)
        } else {
            selectedAddons.insert(addon)
        }
    }

    func isAddonSelected(_ addon: ActiveAddon) -> Bool {
        selectedAddons.contains(addon)
    }

    func fetchOffer() async {
        withAnimation { fetchState = .loading }
        do {
            let data = try await addonService.getAddonRemoveOffer(contractId: contractInfo.contractId)
            withAnimation {
                removeOffer = data
                fetchState = .success
            }
        } catch {
            fetchState = .error(errorMessage: error.localizedDescription)
        }
    }

    func getAddonRemoveOfferCost() async {
        guard removeOffer != nil, fetchingCostState != .loading else { return }
        addonRemoveOfferCost = nil
        withAnimation { fetchingCostState = .loading }
        do {
            addonRemoveOfferCost = try await addonService.getAddonRemoveOfferCost(
                contractId: contractInfo.contractId,
                addonIds: Set(selectedAddons.map(\.id))
            )
            withAnimation { fetchingCostState = .success }
        } catch {
            withAnimation { fetchingCostState = .error(errorMessage: error.localizedDescription) }
        }
    }

    func confirmRemoval() async {
        withAnimation { submittingState = .loading }
        do {
            try await addonService.confirmAddonRemoval(
                contractId: contractInfo.contractId,
                addonIds: Set(selectedAddons.map(\.id))
            )
            withAnimation { submittingState = .success }
        } catch {
            withAnimation { submittingState = .error(errorMessage: error.localizedDescription) }
        }
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        guard let removeOffer, let addonRemoveOfferCost else { return [] }
        var items: [QuoteDisplayItem] = []

        let baseGross = removeOffer.baseCost.premium.gross.formattedAmountPerMonth
        items += [.init(title: removeOffer.productVariant.displayName, value: baseGross)]

        items += removeOffer.removableAddons.map { addon in
            .init(
                title: addon.displayTitle,
                value: addon.cost.premium.gross.formattedAmountPerMonth,
                crossDisplayTitle: isAddonSelected(addon)
            )
        }

        items += addonRemoveOfferCost.discounts.map { discount in
            .init(title: discount.displayName, value: discount.displayValue)
        }

        return items
    }

    func getPremium() -> Premium {
        addonRemoveOfferCost?.premium ?? .zeroSek
    }
}
