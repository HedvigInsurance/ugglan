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
    let addonSource: AddonSource
    let config: AddonConfig

    init(config: AddonConfig, addonSource: AddonSource) {
        self.config = config
        self.addonSource = addonSource
        Task {
            await getAddons()

            if let selectable = addonOffer?.selectableAddons.first {
                selectedAddonIds = [selectable.id]
            }
        }
    }

    var disableDropDown: Bool {
        guard let addonOffer else { return true }
        return addonOffer.allAddons.count == 1
    }

    var allowToContinue: Bool {
        !selectedAddonIds.isEmpty
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
            let data = try await addonService.getAddonOffers(contractId: config.contractId)

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
                selectedAddonIds: selectedAddonIds
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
        guard let addonOffer else { return }
        let logType = addonOffer.addonType.asLoggingAddonType()
        let eventType = addonOffer.addonType.asLoggingAddonEventType(hasActiveAddons: addonOffer.hasActiveAddons)
        selectedAddons.map(\.addonVariant.product)
            .forEach { selectedSubtype in
                let logInfo = AddonLogInfo(
                    flow: addonSource,
                    subType: selectedSubtype,
                    type: logType
                )
                log.addUserAction(
                    type: .custom,
                    name: eventType.rawValue,
                    error: nil,
                    attributes: logInfo.asAddonAttributes
                )
            }
    }

    func getGrossPriceDifference(for addonOfferQuote: AddonOfferQuote) -> MonetaryAmount {
        guard let currentGrossPrice = addonOfferQuote.cost.premium.gross else { return .sek(0) }
        let activeAddonGrossPrice = addonOffer?.activeAddons.first?.cost.premium.gross?.value ?? 0
        return .init(
            amount: currentGrossPrice.value - activeAddonGrossPrice,
            currency: currentGrossPrice.currency
        )
    }

    func getPriceIncrease() -> Premium {
        guard let addonOffer else { return .init(gross: .sek(0), net: .sek(0)) }
        let currency = addonOffer.currentTotalCost.premium.gross?.currency ?? "SEK"
        let currentAddonsNetPrice = addonOffer.activeAddons.compactMap(\.cost.premium.net?.value).reduce(0, +)
        let purchasedAddonsNetPrice = selectedAddons.compactMap(\.cost.premium.net?.value).reduce(0, +)
        let currentAddonsGrossPrice = addonOffer.activeAddons.compactMap(\.cost.premium.gross?.value).reduce(0, +)
        let purchasedAddonsGrossPrice = selectedAddons.compactMap(\.cost.premium.gross?.value).reduce(0, +)

        switch (addonOffer.addonType) {
        case .car:
            return .init(
                gross: .init(amount: purchasedAddonsGrossPrice, currency: currency),
                net: .init(amount: purchasedAddonsNetPrice, currency: currency)
            )
        case .travel:
            return .init(
                gross: .init(amount: purchasedAddonsGrossPrice - currentAddonsGrossPrice, currency: currency),
                net: .init(amount: purchasedAddonsNetPrice - currentAddonsNetPrice, currency: currency)
            )
        }
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        guard let addonOffer else { return [] }
        var items: [QuoteDisplayItem] = []

        let baseTitle = addonOffer.quote.displayTitle
        let baseGross = addonOffer.quote.baseQuoteCost.premium.gross!.formattedAmountPerMonth
        items.append(.init(title: baseTitle, value: baseGross))

        let crossDisplayTitle =
            switch addonOffer.addonType {
            case .car: false
            case .travel: true
            }

        items += addonOffer.activeAddons.map { activeAddon in
            .init(
                title: activeAddon.displayTitle,
                value: activeAddon.cost.premium.gross?.formattedAmountPerMonth ?? "",
                crossDisplayTitle: crossDisplayTitle
            )
        }

        items += selectedAddons.map { selectedAddon in
            .init(
                title: selectedAddon.displayTitle,
                value: selectedAddon.cost.premium.gross?.formattedAmountPerMonth ?? ""
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

    public func getTotalPrice() -> Premium {
        guard let addonOffer else { return .zeroSek }
        switch addonOffer.addonType {
        case .car:
            return getCarTotalPrice()
        case .travel:
            return getTravelTotalPrice()
        }
    }

    private func getCarTotalPrice() -> Premium {
        let selectedQuotes = selectedAddons
        guard !selectedQuotes.isEmpty, let addonOffer else { return .zeroSek }

        let baseGross = addonOffer.quote.baseQuoteCost.premium.gross
        let baseNet = addonOffer.quote.baseQuoteCost.premium.net

        let addonsGross = selectedQuotes.reduce(Float(0)) { sum, quote in
            sum + (quote.cost.premium.gross?.floatAmount ?? 0)
        }
        let addonsNet = selectedQuotes.reduce(Float(0)) { sum, quote in
            sum + (quote.cost.premium.net?.floatAmount ?? 0)
        }

        let currency = baseGross?.currency ?? "SEK"

        let totalGross = MonetaryAmount(
            amount: (baseGross?.floatAmount ?? 0) + addonsGross,
            currency: currency
        )
        let totalNet = MonetaryAmount(
            amount: (baseNet?.floatAmount ?? 0) + addonsNet,
            currency: currency
        )

        return .init(gross: totalGross, net: totalNet)
    }

    private func getTravelTotalPrice() -> Premium {
        guard let addonOffer else { return .zeroSek }
        let selectedQuote = addonOffer.quote.selectableAddons.filter { selectedAddonIds.contains($0.id) }.first
        let currency = selectedQuote?.cost.premium.gross?.currency ?? "SEK"

        if addonOffer.hasActiveAddons {
            // Upgrade scenario: return difference
            guard let selectedQuoteNet = selectedQuote?.cost.premium.net,
                let currentAddonNet = addonOffer.activeAddons.first?.cost.premium.net
            else {
                let zero = MonetaryAmount(amount: 0, currency: currency)
                return .init(gross: zero, net: zero)
            }

            let netAmount = selectedQuoteNet.floatAmount - currentAddonNet.floatAmount
            let netDiff = MonetaryAmount(amount: netAmount, currency: selectedQuoteNet.currency)

            // For upgrades, gross is same as net (no separate gross calculation for difference)
            return .init(gross: netDiff, net: netDiff)
        } else {
            guard let baseGross = addonOffer.quote.baseQuoteCost.premium.gross,
                let baseNet = addonOffer.quote.baseQuoteCost.premium.net,
                let addonGross = selectedQuote?.cost.premium.gross,
                let addonNet = selectedQuote?.cost.premium.net
            else {
                let zero = MonetaryAmount(amount: 0, currency: currency)
                return .init(gross: zero, net: zero)
            }

            let totalGross = MonetaryAmount(amount: baseGross.floatAmount + addonGross.floatAmount, currency: currency)
            let totalNet = MonetaryAmount(amount: baseNet.floatAmount + addonNet.floatAmount, currency: currency)

            return .init(gross: totalGross, net: totalNet)
        }
    }

    func getPremium() -> Premium {
        guard let addonOffer, !selectedAddons.isEmpty else { return .zeroSek }

        let currency = addonOffer.quote.baseQuoteCost.premium.gross?.currency ?? "SEK"

        let baseGross = addonOffer.quote.baseQuoteCost.premium.gross?.floatAmount ?? 0
        let baseNet = addonOffer.quote.baseQuoteCost.premium.net?.floatAmount ?? 0

        let activeAddons = addonOffer.activeAddons
        let activeGross = activeAddons.compactMap(\.cost.premium.gross?.floatAmount).reduce(Float(0), +)
        let activeNet = activeAddons.compactMap(\.cost.premium.net?.floatAmount).reduce(Float(0), +)

        let selectedGross = selectedAddons.compactMap(\.cost.premium.gross?.floatAmount).reduce(Float(0), +)
        let selectedNet = selectedAddons.compactMap(\.cost.premium.net?.floatAmount).reduce(Float(0), +)

        let totalGross: Float
        let totalNet: Float

        switch addonOffer.addonType {
        case .car:
            totalGross = baseGross + selectedGross + activeGross
            totalNet = baseNet + selectedNet + activeNet
        case .travel:
            totalGross = baseGross + selectedGross
            totalNet = baseNet + selectedNet
        }

        return Premium(
            gross: MonetaryAmount(amount: totalGross, currency: currency),
            net: MonetaryAmount(amount: totalNet, currency: currency)
        )
    }

    func getDisplayItems() -> [QuoteDisplayItem] {
        let allDisplayItems = selectedAddons.flatMap { $0.displayItems }
        return compareAddonDisplayItems(newDisplayItems: allDisplayItems)
    }
}

extension AddonType {
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
