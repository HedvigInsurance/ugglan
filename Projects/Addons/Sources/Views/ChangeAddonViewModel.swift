import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    var addonService = AddonsService()
    @Published var fetchAddonsViewState: ProcessingState = .loading
    @Published var submittingAddonsViewState: ProcessingState = .loading
    @Published var addonOffer: AddonOffer?
    @Published var selectedAddons: Set<AddonOfferQuote> = []
    let addonSource: AddonSource
    let config: AddonConfig

    init(config: AddonConfig, addonSource: AddonSource) {
        self.config = config
        self.addonSource = addonSource
        Task {
            await getAddons()

            if case let .selectable(selectableAddon) = addonOffer?.quote.addonOfferContent,
                let first = selectableAddon.quotes.first
            {
                selectedAddons = [first]
            }
        }
    }

    func isDropDownDisabled(for selectableOffer: AddonOfferSelectable) -> Bool {
        selectableOffer.quotes.count <= 1
    }

    var allowToContinue: Bool {
        !selectedAddons.isEmpty
    }

    func isAddonSelected(_ addon: AddonOfferQuote) -> Bool {
        selectedAddons.contains(addon)
    }

    func selectAddon(addon: AddonOfferQuote) {
        guard let addonOffer else { return }
        switch addonOffer.quote.addonOfferContent {
        case .selectable:
            selectedAddons = [addon]
        case .toggleable:
            if selectedAddons.contains(addon) {
                selectedAddons.remove(addon)
            } else {
                selectedAddons.insert(addon)
            }
        }
    }

    func getAddons() async {
        withAnimation { fetchAddonsViewState = .loading }

        do {
            let data = try await addonService.getAddonOffer(contractId: config.contractId)

            withAnimation {
                addonOffer = data
                fetchAddonsViewState = .success
            }
        } catch {
            fetchAddonsViewState = .error(errorMessage: error.localizedDescription)
        }
    }

    func submitAddons() async {
        withAnimation {
            self.submittingAddonsViewState = .loading
        }
        do {
            try await addonService.submitAddons(
                quoteId: addonOffer?.quote.quoteId ?? "",
                selectedAddonIds: Set(selectedAddons.map(\.id))
            )
            logAddonEvent()
            withAnimation {
                self.submittingAddonsViewState = .success
            }
        } catch let exception {
            withAnimation {
                self.submittingAddonsViewState = .error(errorMessage: exception.localizedDescription)
            }
        }
    }

    private func logAddonEvent() {
        selectedAddons.forEach { addon in
            let logInfo = AddonLogInfo(
                flow: addonSource,
                type: addon.addonVariant.product,
                subType: addon.addonVariant.product
            )
            log.addUserAction(
                type: .custom,
                name: addon.addonVariant.product,
                attributes: logInfo.asAddonAttributes
            )
        }
    }

    func getGrossPriceDifference(for addonOfferQuote: AddonOfferQuote) -> MonetaryAmount {
        let currentGrossPrice = addonOfferQuote.cost.premium.gross

        guard let activeAddonGrossPrice = addonOffer?.quote.activeAddons.first?.cost.premium.gross else {
            return currentGrossPrice
        }
        return currentGrossPrice - activeAddonGrossPrice
    }

    func getPriceIncrease() -> Premium? {
        guard let addonOffer, !selectedAddons.isEmpty else { return nil }

        let currentAddonsPremium = addonOffer.quote.activeAddons.map(\.cost.premium).sum()
        let purchasedAddonsPremium = selectedAddons.map(\.cost.premium).sum()

        return switch addonOffer.quote.addonOfferContent {
        case .toggleable: purchasedAddonsPremium
        case .selectable: purchasedAddonsPremium - currentAddonsPremium
        }
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        guard let addonOffer else { return [] }
        var items: [QuoteDisplayItem] = []

        let baseTitle = config.displayName
        let baseGross = addonOffer.quote.baseQuoteCost.premium.gross.formattedAmountPerMonth
        items.append(.init(title: baseTitle, value: baseGross))

        let crossDisplayTitle =
            switch addonOffer.quote.addonOfferContent {
            case .toggleable: false
            case .selectable: true
            }

        items += addonOffer.quote.activeAddons.map { activeAddon in
            .init(
                title: activeAddon.displayTitle,
                value: activeAddon.cost.premium.gross.formattedAmountPerMonth,
                crossDisplayTitle: crossDisplayTitle
            )
        }

        items += selectedAddons.map { selectedAddon in
            .init(
                title: selectedAddon.displayTitle,
                value: selectedAddon.cost.premium.gross.formattedAmountPerMonth
            )
        }

        items += addonOffer.quote.baseQuoteCost.discounts.map { discount in
            .init(title: discount.displayName, value: discount.displayValue)
        }

        return items
    }

    func getPremium() -> Premium {
        guard let addonOffer, !selectedAddons.isEmpty else { return .zeroSek }

        let basePremium = addonOffer.quote.baseQuoteCost.premium
        let activePremium = addonOffer.quote.activeAddons.map(\.cost.premium).sum()
        let selectedPremium = selectedAddons.map(\.cost.premium).sum()

        return switch addonOffer.quote.addonOfferContent {
        case .toggleable: basePremium + activePremium + selectedPremium
        case .selectable: basePremium + selectedPremium
        }
    }
}

extension AddonDisplayItem {
    public func asQuoteDisplayItem() -> QuoteDisplayItem {
        .init(title: displayTitle, value: displayValue)
    }
}
