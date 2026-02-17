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

    init(_ contractInfo: AddonConfig) {
        self.contractInfo = contractInfo
        Task { await fetchOffer() }
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
        withAnimation {
            self.submittingState = .loading
        }
        do {
            try await addonService.confirmAddonRemoval(
                contractId: contractInfo.contractId,
                addonIds: Set(selectedAddons.map(\.id))
            )
            withAnimation {
                self.submittingState = .success
            }
        } catch {
            withAnimation {
                self.submittingState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        guard let removeOffer else { return [] }
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

        items += removeOffer.currentTotalCost.discounts.map { discount in
            .init(title: discount.displayName, value: discount.displayValue)
        }

        return items
    }

    func getNewPremium() -> Premium {
        guard let removeOffer else { return .zeroSek }
        let removedPremium = removeOffer.removableAddons
            .filter { selectedAddonIds.contains($0.id) }
            .map(\.cost.premium)
            .sum()
        return removeOffer.currentTotalCost.premium - removedPremium
    }

    func getCurrentAndNewPrice() -> Premium {
        guard let removeOffer else { return .zeroSek }
        let newPremium = getNewPremium()
        return Premium(gross: removeOffer.currentTotalCost.premium.gross, net: newPremium.gross)
    }
}
