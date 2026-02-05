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

            if let selectable = selectableAddons.first {
                selectedAddonIds = [selectable.id]
            }
        }
    }

    func disableDropDown(for selectable: AddonOfferSelectable) -> Bool {
        selectable.quotes.count <= 1
    }

    var selectableAddons: [AddonOfferQuote] {
        addonOffer?.quote.selectableAddons ?? []
    }

    var toggleableAddons: [AddonOfferQuote] {
        addonOffer?.quote.toggleableAddons ?? []
    }

    var activeAddons: [ActiveAddon] {
        addonOffer?.quote.activeAddons ?? []
    }

    var activationDate: Date? {
        addonOffer?.quote.activationDate
    }

    var allowToContinue: Bool {
        !selectedAddonIds.isEmpty
    }

    func selectedQuote(for selectable: AddonOfferSelectable) -> AddonOfferQuote? {
        selectable.quotes.first { selectedAddonIds.contains($0.id) }
    }

    func isAddonSelected(_ addon: AddonOfferQuote) -> Bool {
        selectedAddonIds.contains(addon.id)
    }

    func selectAddon(id: String, addonType: AddonType) {
        switch (addonType) {
        case .travel:
            selectedAddonIds = [id]
        case .car:
            if selectedAddonIds.contains(id) {
                selectedAddonIds.remove(id)
            } else {
                selectedAddonIds.insert(id)
            }
        }
    }

    var selectedAddons: [AddonOfferQuote] {
        addonOffer?.quote.addons.filter { selectedAddonIds.contains($0.id) } ?? []
    }

    func getAddons() async {
        withAnimation { fetchAddonsViewState = .loading }

        do {
            let data = try await addonService.getAddonOffers(contractId: contractId)
            let selectableAddons = data.quote.selectableAddons
            let toggleableAddons = data.quote.toggleableAddons

            let type: AddonType =
                switch (selectableAddons.isEmpty, toggleableAddons.isEmpty) {
                case (false, true):
                    .travel
                case (true, false):
                    .car
                default:
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
        selectedAddons.map(\.addonVariant.product)
            .forEach { selectedSubtype in
                guard let addonType else { return }
                let logInfoModel = AddonLogInfo(
                    flow: addonSource,
                    subType: selectedSubtype,
                    type: addonType.asLoggingAddonType()
                )
                let eventType = addonType.asLoggingAddonEventType(hasActiveAddons: !activeAddons.isEmpty)
                log.addUserAction(
                    type: .custom,
                    name: eventType.rawValue,
                    error: nil,
                    attributes: logInfoModel.asAddonAttributes
                )
            }
    }

    func getPriceDifference(for addonOffer: AddonOfferQuote) -> MonetaryAmount? {
        let activeAddonPrice = activeAddons.first?.cost.premium.gross!.value ?? 0
        let diff = addonOffer.cost.premium.gross!.value - activeAddonPrice
        let currency = addonOffer.cost.premium.gross!.currency

        return .init(amount: diff, currency: currency)
    }

    func getPriceIncrease(
        offer: AddonOfferV2,
        for addonType: AddonType
    ) -> (net: MonetaryAmount, gross: MonetaryAmount) {
        let currency = offer.currentTotalCost.premium.gross!.currency
        let currentAddonsNetPrice = activeAddons.map(\.cost.premium.net!.value).reduce(0, +)
        let purchasedAddonsNetPrice = selectedAddons.map(\.cost.premium.net!.value).reduce(0, +)
        let currentAddonsGrossPrice = activeAddons.map(\.cost.premium.gross!.value).reduce(0, +)
        let purchasedAddonsGrossPrice = selectedAddons.map(\.cost.premium.gross!.value).reduce(0, +)

        switch (addonType) {
        case .car:
            return (
                net: .init(amount: purchasedAddonsNetPrice, currency: currency),
                gross: .init(amount: purchasedAddonsGrossPrice, currency: currency)
            )
        case .travel:
            return (
                net: .init(amount: purchasedAddonsNetPrice - currentAddonsNetPrice, currency: currency),
                gross: .init(amount: purchasedAddonsGrossPrice - currentAddonsGrossPrice, currency: currency)
            )
        }
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        guard let addonOffer, let addonType else { return [] }
        var items: [QuoteDisplayItem] = []

        let baseTitle = addonOffer.quote.displayTitle
        let baseGross = addonOffer.currentTotalCost.premium.gross!.formattedAmountPerMonth
        items.append(.init(title: baseTitle, value: baseGross))

        let crossDisplayTitle =
            switch addonType {
            case .car: false
            case .travel: true
            }

        items += activeAddons.map { activeAddon in
            .init(
                title: activeAddon.displayDescription!,
                value: activeAddon.cost.premium.gross!.formattedAmountPerMonth,
                crossDisplayTitle: crossDisplayTitle
            )
        }

        items += selectedAddons.map { selectedAddon in
            .init(
                title: selectedAddon.addonVariant.displayName,
                value: selectedAddon.cost.premium.gross!.formattedAmountPerMonth
            )
        }

        items += addonOffer.quote.baseQuoteCost.discounts.map { discount in
            .init(title: discount.displayName, value: discount.displayValue)
        }

        return items
    }

    func compareAddonDisplayItems(newDisplayItems: [AddonDisplayItem]) -> [QuoteDisplayItem] {
        let displayItems: [QuoteDisplayItem] = newDisplayItems.map { item in
            .init(title: item.displayTitle, value: item.displayValue)
        }
        return displayItems
    }

    public func getTotalPrice() -> (net: MonetaryAmount, gross: MonetaryAmount) {
        switch addonType {
        case .car:
            return getCarTotalPrice()
        case .travel:
            return getTravelTotalPrice()
        case .none:
            let zero = MonetaryAmount(amount: 0, currency: "SEK")
            return (net: zero, gross: zero)
        }
    }

    private func getCarTotalPrice() -> (net: MonetaryAmount, gross: MonetaryAmount) {
        let selectedQuotes = selectedAddons
        guard !selectedQuotes.isEmpty else {
            let zero = MonetaryAmount(amount: 0, currency: "SEK")
            return (net: zero, gross: zero)
        }

        let baseGross = addonOffer?.quote.baseQuoteCost.premium.gross
        let baseNet = addonOffer?.quote.baseQuoteCost.premium.net

        let addonsGross = selectedQuotes.reduce(Float(0)) { sum, quote in
            sum + (quote.cost.premium.gross?.floatAmount ?? 0)
        }
        let addonsNet = selectedQuotes.reduce(Float(0)) { sum, quote in
            sum + (quote.cost.premium.net?.floatAmount ?? 0)
        }

        let currency = baseGross?.currency ?? selectedQuotes.first?.cost.premium.gross?.currency ?? "SEK"

        let totalGross = MonetaryAmount(
            amount: (baseGross?.floatAmount ?? 0) + addonsGross,
            currency: currency
        )
        let totalNet = MonetaryAmount(
            amount: (baseNet?.floatAmount ?? 0) + addonsNet,
            currency: currency
        )

        return (net: totalNet, gross: totalGross)
    }

    private func getTravelTotalPrice() -> (net: MonetaryAmount, gross: MonetaryAmount) {
        let selectedQuote = addonOffer!.quote.selectableAddons.filter { selectedAddonIds.contains($0.id) }.first
        let currency = selectedQuote?.cost.premium.gross?.currency ?? "SEK"

        if !activeAddons.isEmpty {
            // Upgrade scenario: return difference
            guard let selectedQuoteNet = selectedQuote?.cost.premium.net,
                let currentAddonNet = activeAddons.first?.cost.premium.net
            else {
                let zero = MonetaryAmount(amount: 0, currency: currency)
                return (net: zero, gross: zero)
            }

            let netAmount = selectedQuoteNet.floatAmount - currentAddonNet.floatAmount
            let netDiff = MonetaryAmount(amount: netAmount, currency: selectedQuoteNet.currency)

            // For upgrades, gross is same as net (no separate gross calculation for difference)
            return (net: netDiff, gross: netDiff)
        } else {
            guard let baseGross = addonOffer?.quote.baseQuoteCost.premium.gross,
                let baseNet = addonOffer?.quote.baseQuoteCost.premium.net,
                let addonGross = selectedQuote?.cost.premium.gross,
                let addonNet = selectedQuote?.cost.premium.net
            else {
                let zero = MonetaryAmount(amount: 0, currency: currency)
                return (net: zero, gross: zero)
            }

            let totalGross = MonetaryAmount(amount: baseGross.floatAmount + addonGross.floatAmount, currency: currency)
            let totalNet = MonetaryAmount(amount: baseNet.floatAmount + addonNet.floatAmount, currency: currency)

            return (net: totalNet, gross: totalGross)
        }
    }

    func getPremium() -> Premium? {
        switch addonType {
        case .car:
            return getCarPremium()
        case .travel:
            return getTravelPremium()
        case .none:
            return nil
        }
    }

    private func getCarPremium() -> Premium? {
        let selectedQuotes = selectedAddons
        guard !selectedQuotes.isEmpty else {
            return nil
        }

        let baseGross = addonOffer?.quote.baseQuoteCost.premium.gross
        let baseNet = addonOffer?.quote.baseQuoteCost.premium.net

        let addonsGross = selectedQuotes.reduce(Float(0)) { sum, quote in
            sum + (quote.cost.premium.gross?.floatAmount ?? 0)
        }
        let addonsNet = selectedQuotes.reduce(Float(0)) { sum, quote in
            sum + (quote.cost.premium.net?.floatAmount ?? 0)
        }

        let currency = baseGross?.currency ?? selectedQuotes.first?.cost.premium.gross?.currency ?? "SEK"

        let totalGross = MonetaryAmount(
            amount: (baseGross?.floatAmount ?? 0) + addonsGross,
            currency: currency
        )
        let totalNet = MonetaryAmount(
            amount: (baseNet?.floatAmount ?? 0) + addonsNet,
            currency: currency
        )

        return Premium(gross: totalGross, net: totalNet)
    }

    private func getTravelPremium() -> Premium? {
        let selectedQuote = addonOffer!.quote.selectableAddons.filter { selectedAddonIds.contains($0.id) }.first

        if !activeAddons.isEmpty {
            return Premium(
                gross: nil,
                net: selectedQuote?.cost.premium.net
            )
        } else {
            let baseGross = addonOffer?.quote.baseQuoteCost.premium.gross
            let baseNet = addonOffer?.quote.baseQuoteCost.premium.net
            let addonGross = selectedQuote?.cost.premium.gross
            let addonNet = selectedQuote?.cost.premium.net

            guard let bg = baseGross, let bn = baseNet,
                let ag = addonGross, let an = addonNet
            else {
                return selectedQuote?.cost.premium
            }

            // Total gross = base gross + addon gross
            let totalGross = MonetaryAmount(amount: bg.floatAmount + ag.floatAmount, currency: bg.currency)
            // Total net = base net + addon net (discounts already reflected in net prices)
            let totalNet = MonetaryAmount(amount: bn.floatAmount + an.floatAmount, currency: bn.currency)

            return Premium(gross: totalGross, net: totalNet)
        }
    }

    func getDisplayItems() -> [QuoteDisplayItem] {
        let allDisplayItems = selectedAddons.flatMap { $0.displayItems }
        return compareAddonDisplayItems(newDisplayItems: allDisplayItems)
    }
}

enum AddonType {
    case travel, car

    func asLoggingAddonType() -> AddonLogInfo.AddonType {
        switch self {
        case .travel: return .travelAddon
        case .car: return .carAddon
        }
    }

    func asLoggingAddonEventType(hasActiveAddons: Bool) -> AddonEventType {
        switch self {
        case .travel: return hasActiveAddons ? .addonUpgraded : .addonPurchased
        case .car: return .addonPurchased
        }
    }
}
