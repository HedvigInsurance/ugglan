import SwiftUI
import hCore
import hCoreUI

@MainActor
class RemoveAddonViewModel: ObservableObject {
    let addonService = AddonsService()
    @Published var submittingState: ProcessingState = .loading
    @Published var removeOffer: AddonRemoveOffer
    @Published var selectedAddons: Set<ActiveAddon> = []
    @Published var addonRemoveOfferCost: ItemCost?
    @Published var fetchingCostState: ProcessingState = .success
    init(_ removeOffer: AddonRemoveOfferWithSelectedItems) {
        self.removeOffer = removeOffer.offer
        self.selectedAddons = Set(
            self.removeOffer.removableAddons.filter { removeOffer.preselectedAddons.contains($0.displayTitle) }
        )
        self.addonRemoveOfferCost = removeOffer.cost
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

    func getAddonRemoveOfferCost() async {
        guard fetchingCostState != .loading else { return }
        addonRemoveOfferCost = nil
        withAnimation { fetchingCostState = .loading }
        do {
            addonRemoveOfferCost = try await addonService.getAddonRemoveOfferCost(
                contractId: removeOffer.contractInfo.contractId,
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
                contractId: removeOffer.contractInfo.contractId,
                addonIds: Set(selectedAddons.map(\.id))
            )
            withAnimation { submittingState = .success }
        } catch {
            withAnimation { submittingState = .error(errorMessage: error.localizedDescription) }
        }
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        guard let addonRemoveOfferCost else { return [] }
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
