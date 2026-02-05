import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    var addonService = AddonsService()
    @Published var fetchAddonsViewState: ProcessingState = .loading
    @Published var submittingAddonsViewState: ProcessingState = .loading
    @Published var addonOffer: AddonOfferV2?
    @Published var selectedAddonIds: Set<String> = []
    @Published var addonType: AddonType? = nil
    let contractId: String
    let addonSource: AddonSource

    init(contractId: String, addonSource: AddonSource) {
        self.contractId = contractId
        self.addonSource = addonSource
        Task {
            await getAddons()
            // Pre-select first quote from each selectable
            for selectable in selectableAddons {
                if let firstQuote = selectable.quotes.first {
                    selectedAddonIds.insert(firstQuote.id)
                }
            }
        }
    }

    func disableDropDown(for selectable: AddonOfferSelectable) -> Bool {
        selectable.quotes.count <= 1
    }

    var addons: [AddonOfferContent] {
        addonOffer?.quote.addonOffers ?? []
    }

    var selectableAddons: [AddonOfferSelectable] {
        addonOffer?.quote.addonOffers
            .compactMap {
                if case .selectable(let s) = $0 { return s }
                return nil
            } ?? []
    }

    var toggleableAddons: [AddonOfferToggleable] {
        addonOffer?.quote.addonOffers
            .compactMap {
                if case .toggleable(let s) = $0 { return s }
                return nil
            } ?? []
    }

    var activeAddons: [ActiveAddon] {
        addonOffer?.quote.activeAddons ?? []
    }

    var activationDate: Date? {
        addonOffer?.quote.activationDate
    }

    func selectedQuote(for selectable: AddonOfferSelectable) -> AddonOfferQuote? {
        selectable.quotes.first { selectedAddonIds.contains($0.id) }
    }

    func selectQuote(_ quote: AddonOfferQuote, for selectable: AddonOfferSelectable) {
        // Remove existing selection from this group
        let groupIds = Set(selectable.quotes.map { $0.id })
        selectedAddonIds.subtract(groupIds)
        selectedAddonIds.insert(quote.id)
    }

    func getAddons() async {
        withAnimation { fetchAddonsViewState = .loading }

        do {
            let data = try await addonService.getAddonOffers(contractId: contractId)
            let offers = data.quote.addonOffers

            let type: AddonType
            if offers.count == 1, case .selectable = offers[0] {
                type = .travel
            } else if offers.allSatisfy({ if case .toggleable = $0 { true } else { false } }) {
                type = .car
            } else {
                throw AddonsError.somethingWentWrong
            }

            withAnimation {
                addonOffer = data
                addonType = type
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
                selectedAddonsIds: selectedAddonIds
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
        // Get first selected quote's subtype for logging
        let selectedSubtype =
            selectableAddons.compactMap { selectable in
                selectedQuote(for: selectable)?.addonVariant.product
            }
            .first ?? ""

        let logInfoModel = AddonLogInfo(
            flow: addonSource,
            subType: selectedSubtype,
            type: .travelAddon
        )
        let actionType = activeAddons.isEmpty ? AddonEventType.addonPurchased : AddonEventType.addonUpgraded
        log.addUserAction(
            type: .custom,
            name: actionType.rawValue,
            error: nil,
            attributes: logInfoModel.asAddonAttributes
        )
    }

    func getPriceForQuote(_ quote: AddonOfferQuote?, in selectable: AddonOfferSelectable) -> MonetaryAmount? {
        guard let quote else { return nil }

        // If there are active addons, calculate the difference
        if let activeAddon = activeAddons.first,
            let activeNet = activeAddon.cost.premium.net,
            let quoteNet = quote.cost.premium.net
        {
            let diff = quoteNet.value - activeNet.value
            return MonetaryAmount(amount: diff.asString, currency: quoteNet.currency)
        }

        return quote.cost.premium.net
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        if let activeAddon = activeAddons.first {
            // Upgrade scenario: show current addon with strikethrough and new selection
            let currentAddonBreakdownDisplayItems = QuoteDisplayItem(
                title: activeAddon.displayTitle,
                value: activeAddon.cost.premium.net?.formattedAmountPerMonth ?? "",
                crossDisplayTitle: true
            )

            let selectedQuoteInfo = selectableAddons.first.flatMap { selectedQuote(for: $0) }
            let selectedAddonBreakdownDisplayItems = QuoteDisplayItem(
                title: selectedQuoteInfo?.addonVariant.displayName ?? "",
                value: selectedQuoteInfo?.cost.premium.net?.formattedAmountPerMonth ?? ""
            )

            return [currentAddonBreakdownDisplayItems, selectedAddonBreakdownDisplayItems]
        } else {
            // New addon scenario: show full agreement breakdown
            var items: [QuoteDisplayItem] = []

            // 1. Base quote (Home Insurance): gross price
            if let baseGross = addonOffer?.quote.baseQuoteCost.premium.gross {
                let baseName = addonOffer?.quote.productVariant.displayName ?? ""
                items.append(
                    QuoteDisplayItem(
                        title: baseName,
                        value: baseGross.formattedAmountPerMonth
                    )
                )
            }

            // 2. Selected addon: gross price
            let selectedQuoteInfo = selectableAddons.first.flatMap { selectedQuote(for: $0) }
            if let addonGross = selectedQuoteInfo?.cost.premium.gross {
                items.append(
                    QuoteDisplayItem(
                        title: selectedQuoteInfo?.addonVariant.displayName ?? "",
                        value: addonGross.formattedAmountPerMonth
                    )
                )
            }

            // 3. Combined discount: total gross - total net (as single line)
            let totalGross =
                (addonOffer?.quote.baseQuoteCost.premium.gross?.floatAmount ?? 0)
                + (selectedQuoteInfo?.cost.premium.gross?.floatAmount ?? 0)
            let totalNet =
                (addonOffer?.quote.baseQuoteCost.premium.net?.floatAmount ?? 0)
                + (selectedQuoteInfo?.cost.premium.net?.floatAmount ?? 0)
            let discountAmount = totalGross - totalNet
            let discountName = selectedQuoteInfo?.cost.discounts.first?.displayName ?? ""

            if discountAmount > 0, let currency = addonOffer?.quote.baseQuoteCost.premium.gross?.currency {
                let discountValue = MonetaryAmount(amount: -discountAmount, currency: currency)
                items.append(
                    QuoteDisplayItem(
                        title: discountName,
                        value: discountValue.formattedAmountPerMonth
                    )
                )
            }

            return items
        }
    }

    func compareAddonDisplayItems(newDisplayItems: [AddonDisplayItem]) -> [QuoteDisplayItem] {
        let displayItems: [QuoteDisplayItem] = newDisplayItems.map { item in
            .init(title: item.displayTitle, value: item.displayValue)
        }
        return displayItems
    }

    func getTotalPrice() -> MonetaryAmount {
        let selectedQuoteInfo = selectableAddons.first.flatMap { selectedQuote(for: $0) }
        guard let selectedQuoteNet = selectedQuoteInfo?.cost.premium.net else {
            return .init(amount: 0, currency: "SEK")
        }

        if let activeAddon = activeAddons.first,
            let currentAddonNet = activeAddon.cost.premium.net
        {
            let amount = selectedQuoteNet.floatAmount - currentAddonNet.floatAmount
            return .init(amount: amount, currency: selectedQuoteNet.currency)
        }
        return selectedQuoteNet
    }

    func getPremium() -> Premium? {
        let selectedQuoteInfo = selectableAddons.first.flatMap { selectedQuote(for: $0) }
        if !activeAddons.isEmpty {
            return Premium(
                gross: nil,
                net: selectedQuoteInfo?.cost.premium.net
            )
        } else {
            let baseGross = addonOffer?.quote.baseQuoteCost.premium.gross
            let baseNet = addonOffer?.quote.baseQuoteCost.premium.net
            let addonGross = selectedQuoteInfo?.cost.premium.gross
            let addonNet = selectedQuoteInfo?.cost.premium.net

            guard let bg = baseGross, let bn = baseNet,
                let ag = addonGross, let an = addonNet
            else {
                return selectedQuoteInfo?.cost.premium
            }

            // Total gross = base gross + addon gross
            let totalGross = MonetaryAmount(amount: bg.floatAmount + ag.floatAmount, currency: bg.currency)
            // Total net = base net + addon net (discounts already reflected in net prices)
            let totalNet = MonetaryAmount(amount: bn.floatAmount + an.floatAmount, currency: bn.currency)

            return Premium(gross: totalGross, net: totalNet)
        }
    }

    func getDisplayItems() -> [QuoteDisplayItem] {
        let selectedQuoteInfo = selectableAddons.first.flatMap { selectedQuote(for: $0) }
        return compareAddonDisplayItems(newDisplayItems: selectedQuoteInfo?.displayItems ?? [])
    }
}

enum AddonType {
    case travel, car
}
