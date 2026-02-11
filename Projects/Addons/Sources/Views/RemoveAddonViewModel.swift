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
    @Published var selectedAddonIds: Set<String> = []

    init(contractInfo: AddonConfig) {
        self.contractInfo = contractInfo
        Task { await fetchOffer() }
    }

    var allowToContinue: Bool {
        !selectedAddonIds.isEmpty
    }

    func toggleAddon(_ addon: ActiveAddon) {
        if selectedAddonIds.contains(addon.id) {
            selectedAddonIds.remove(addon.id)
        } else {
            selectedAddonIds.insert(addon.id)
        }
    }

    func isAddonSelected(_ addon: ActiveAddon) -> Bool {
        selectedAddonIds.contains(addon.id)
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

    func confirmRemoval() async {
        withAnimation {
            self.submittingState = .loading
        }
        do {
            try await addonService.confirmAddonRemoval(
                contractId: contractInfo.contractId,
                addonIds: selectedAddonIds
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

    func getPriceDifference() -> Premium {
        guard let removeOffer else { return .zeroSek }
        let newPremium = getNewPremium()
        return Premium(gross: removeOffer.currentTotalCost.premium.gross, net: newPremium.gross)
    }
}
