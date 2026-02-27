import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    let addonService = AddonsService()
    @Published var submittingAddonsViewState: ProcessingState = .loading
    @Published var addonOfferCost: ItemCost?
    @Published var fetchingCostState: ProcessingState = .success
    @Published private var selectedAddonIds: Set<String> = []
    let offer: AddonOffer

    init(offer: AddonOffer, preselectedAddonTitle: String? = nil) {
        self.offer = offer
        switch offer.quote.addonOfferContent {
        case let .selectable(data):
            if let first = data.quotes.first {
                self.selectedAddonIds = [first.id]
            }
        case let .toggleable(data):
            let preselectedIds = data.quotes
                .filter { $0.displayTitle == preselectedAddonTitle }
                .map(\.id)
            self.selectedAddonIds = Set(preselectedIds)
        }
    }

    public var selectedAddons: [AddonOfferQuote] {
        let availableAddons =
            switch offer.quote.addonOfferContent {
            case .toggleable(let t): t.quotes
            case .selectable(let s): s.quotes
            }

        return availableAddons.filter { isAddonSelected($0) }
    }

    func isDropDownDisabled(for selectableOffer: AddonOfferSelectable) -> Bool {
        selectableOffer.quotes.count <= 1
    }

    var allowToContinue: Bool {
        !selectedAddonIds.isEmpty
    }

    func isAddonSelected(_ addon: AddonOfferQuote) -> Bool {
        selectedAddonIds.contains(addon.id)
    }

    func selectAddon(addon: AddonOfferQuote) {
        addonOfferCost = nil
        switch offer.quote.addonOfferContent {
        case .selectable:
            selectedAddonIds = [addon.id]
        case .toggleable:
            if selectedAddonIds.contains(addon.id) {
                selectedAddonIds.remove(addon.id)
            } else {
                selectedAddonIds.insert(addon.id)
            }
        }
    }

    func submitAddons() async {
        withAnimation {
            self.submittingAddonsViewState = .loading
        }
        do {
            try await addonService.submitAddons(
                quoteId: offer.quote.quoteId,
                selectedAddonIds: Set(selectedAddonIds.map(\.id))
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

    func getAddonOfferCost() async {
        guard fetchingCostState != .loading else { return }
        addonOfferCost = nil
        withAnimation { fetchingCostState = .loading }
        let quoteId = offer.quote.quoteId

        do {
            addonOfferCost = try await addonService.getAddonOfferCost(quoteId: quoteId, addonIds: selectedAddonIds)
            withAnimation { fetchingCostState = .success }
        } catch {
            withAnimation { fetchingCostState = .error(errorMessage: error.localizedDescription) }
        }
    }

    func getGrossPriceDifference(for addonOfferQuote: AddonOfferQuote) -> MonetaryAmount {
        let currentGrossPrice = addonOfferQuote.cost.premium.gross

        guard let activeAddonGrossPrice = offer.quote.activeAddons.first?.cost.premium.gross else {
            return currentGrossPrice
        }
        return currentGrossPrice - activeAddonGrossPrice
    }

    func getAddonPriceChange() -> Premium? {
        guard !selectedAddonIds.isEmpty else { return nil }

        let currentAddonsPremium = offer.quote.activeAddons.map(\.cost.premium).sum()
        let purchasedAddonsPremium = selectedAddons.map(\.cost.premium).sum()

        return switch offer.quote.addonOfferContent {
        case .toggleable: purchasedAddonsPremium
        case .selectable: purchasedAddonsPremium - currentAddonsPremium
        }
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        var items: [QuoteDisplayItem] = []

        let baseTitle = offer.config.exposureName
        let baseGross = offer.quote.baseQuoteCost.premium.gross.formattedAmountPerMonth
        items.append(.init(title: baseTitle, value: baseGross))

        let crossDisplayTitle =
            switch offer.quote.addonOfferContent {
            case .toggleable: false
            case .selectable: true
            }

        items += offer.quote.activeAddons.map { $0.asQuoteDisplayItem(crossDisplayTitle: crossDisplayTitle) }
        items += selectedAddons.map { $0.asQuoteDisplayItem() }
        items += addonOfferCost?.discounts.map { $0.asQuoteDisplayItem() } ?? []

        return items
    }

    func getPremium() -> Premium {
        addonOfferCost?.premium ?? .zeroSek
    }
}

extension AddonDisplayItem {
    public func asQuoteDisplayItem() -> QuoteDisplayItem {
        .init(title: displayTitle, value: displayValue)
    }
}

extension AddonOfferQuote {
    public func asQuoteDisplayItem() -> QuoteDisplayItem {
        .init(title: displayTitle, value: cost.premium.gross.formattedAmountPerMonth)
    }
}

extension ActiveAddon {
    public func asQuoteDisplayItem(crossDisplayTitle: Bool) -> QuoteDisplayItem {
        .init(
            title: displayTitle,
            value: cost.premium.gross.formattedAmountPerMonth,
            crossDisplayTitle: crossDisplayTitle
        )
    }
}

extension ItemDiscount {
    public func asQuoteDisplayItem() -> QuoteDisplayItem {
        .init(title: displayName, value: displayValue)
    }
}

//MARK: Log purchase
extension ChangeAddonViewModel {
    fileprivate func logAddonEvent() {
        let eventType: AddonEventType =
            switch offer.quote.addonOfferContent {
            case .selectable: offer.quote.activeAddons.isEmpty ? .addonPurchased : .addonUpgraded
            case .toggleable: .addonPurchased
            }

        selectedAddons.forEach { addon in
            let logInfo = AddonLogInfo(
                flow: offer.source,
                type: addon.addonVariant.product,
                subType: addon.subtype
            )
            log.addUserAction(
                type: .custom,
                name: eventType.rawValue,
                attributes: logInfo.asAddonAttributes
            )
        }
    }
    private enum AddonEventType: String, Codable {
        case addonPurchased = "ADDON_PURCHASED"
        case addonUpgraded = "ADDON_UPGRADED"
    }
}
