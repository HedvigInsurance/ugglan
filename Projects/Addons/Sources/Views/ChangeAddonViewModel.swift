import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    @Inject private var eventTrackingClient: EventTrackingClient
    let addonService = AddonsService()
    @Published var submittingState: ProcessingState = .loading
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
            self.submittingState = .loading
        }
        do {
            try await addonService.submitAddons(
                quoteId: offer.quote.quoteId,
                selectedAddonIds: Set(selectedAddonIds.map(\.id))
            )
            logAddonEvent()
            trackAddonPurchased()
            withAnimation {
                self.submittingState = .success
            }
        } catch let exception {
            withAnimation {
                self.submittingState = .error(errorMessage: exception.localizedDescription)
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

        let baseTitle = offer.contractInfo.displayName
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
    // A selectable add-on replaces the tier the member already has. Toggleable add-ons sit next to the ones
    // already active, so buying one is never an upgrade.
    fileprivate var isUpgrade: Bool {
        switch offer.quote.addonOfferContent {
        case .selectable: !offer.quote.activeAddons.isEmpty
        case .toggleable: false
        }
    }

    fileprivate func logAddonEvent() {
        let eventType: AddonEventType = isUpgrade ? .addonUpgraded : .addonPurchased

        selectedAddons.forEach { addon in
            let logInfo = AddonLogInfo(
                flow: offer.source,
                type: addon.addonVariant.product,
                subType: addon.subType
            )
            log.addUserAction(
                type: .custom,
                name: eventType.rawValue,
                attributes: logInfo.asAddonAttributes
            )
        }
    }

    // Upgrading an add-on the member already had counts as a purchase, so this fires for upgrades too.
    fileprivate func trackAddonPurchased() {
        selectedAddons.forEach { addon in
            let price = addon.cost.premium.net
            eventTrackingClient.trackEvent(
                name: "addon_purchased",
                parameters: [
                    "user_flow": offer.source.analyticsUserFlow,
                    "addon_type": addon.addonVariant.product,
                    "contract_id": offer.contractInfo.contractId,
                    "price": Double(price.amount) ?? 0,
                    "currency": price.currency,
                    "quote_id": offer.quote.quoteId,
                    "purchase_type": isUpgrade ? "upgrade" : "new",
                ]
            )
        }
    }

    private enum AddonEventType: String, Codable {
        case addonPurchased = "ADDON_PURCHASED"
        case addonUpgraded = "ADDON_UPGRADED"
    }
}

extension AddonSource {
    fileprivate var analyticsUserFlow: String {
        switch self {
        case .insurances: "insurance_screen"
        case .contractDetail: "insurance_card"
        case .homeScreen, .homeCrossSellSheet: "home"
        case .travelCertificates: "travel_certificate"
        case .deeplink: "deeplink"
        }
    }
}
