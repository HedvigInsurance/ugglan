import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    var addonService = AddonsService()
    @Published var fetchAddonsViewState: ProcessingState = .loading
    @Published var submittingAddonsViewState: ProcessingState = .loading
    @Published var addonOffer: AddonOfferV2?
    @Published var selectedAddons: Set<AddonOfferQuote> = []
    let addonSource: AddonSource
    let config: AddonConfig

    init(config: AddonConfig, addonSource: AddonSource) {
        self.config = config
        self.addonSource = addonSource
        Task {
            await getAddons()

            if let selectableAddon = addonOffer?.selectableAddons.first {
                selectedAddons = [selectableAddon]
            }
        }
    }

    var disableDropDown: Bool {
        guard let addonOffer else { return true }
        return addonOffer.allAddons.count == 1
    }

    var allowToContinue: Bool {
        !selectedAddons.isEmpty
    }

    func isAddonSelected(_ addon: AddonOfferQuote) -> Bool {
        selectedAddons.contains(addon)
    }

    func selectAddon(addon: AddonOfferQuote) {
        guard let addonType = addonOffer?.addonType else { return }
        switch (addonType) {
        case .travel:
            selectedAddons = [addon]
        case .car:
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
        let currentGrossPrice = addonOfferQuote.cost.premium.gross

        guard let activeAddonGrossPrice = addonOffer?.activeAddons.first?.cost.premium.gross else {
            return currentGrossPrice
        }
        return currentGrossPrice - activeAddonGrossPrice
    }

    func getPriceIncrease() -> Premium {
        guard let addonOffer else { return .init(gross: .sek(0), net: .sek(0)) }

        let currentAddonsPremium = addonOffer.activeAddons.map(\.cost.premium).sum()
        let purchasedAddonsPremium = selectedAddons.map(\.cost.premium).sum()

        return switch (addonOffer.addonType) {
        case .car: purchasedAddonsPremium
        case .travel: purchasedAddonsPremium - currentAddonsPremium
        }
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        guard let addonOffer else { return [] }
        var items: [QuoteDisplayItem] = []

        let baseTitle = addonOffer.quote.displayTitle
        let baseGross = addonOffer.quote.baseQuoteCost.premium.gross.formattedAmountPerMonth
        items.append(.init(title: baseTitle, value: baseGross))

        let crossDisplayTitle =
            switch addonOffer.addonType {
            case .car: false
            case .travel: true
            }

        items += addonOffer.activeAddons.map { activeAddon in
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

    func compareAddonDisplayItems(newDisplayItems: [AddonDisplayItem]) -> [QuoteDisplayItem] {
        let displayItems: [QuoteDisplayItem] = newDisplayItems.map { item in
            .init(title: item.displayTitle, value: item.displayValue)
        }
        return displayItems
    }

    func getPremium() -> Premium {
        guard let addonOffer, !selectedAddons.isEmpty else { return .zeroSek }

        let basePremium = addonOffer.quote.baseQuoteCost.premium
        let activePremium = addonOffer.activeAddons.map(\.cost.premium).sum()
        let selectedPremium = selectedAddons.map(\.cost.premium).sum()

        return switch addonOffer.addonType {
        case .car: basePremium + activePremium + selectedPremium
        case .travel: basePremium + selectedPremium
        }
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
