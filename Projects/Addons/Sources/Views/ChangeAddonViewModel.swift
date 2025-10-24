import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    var addonService = AddonsService()
    @Published var fetchAddonsViewState: ProcessingState = .loading
    @Published var submittingAddonsViewState: ProcessingState = .loading
    @Published var selectedQuote: AddonQuote?
    @Published var addonOffer: AddonOffer?
    let contractId: String
    let addonSource: AddonSource
    init(contractId: String, addonSource: AddonSource) {
        self.contractId = contractId
        self.addonSource = addonSource
        Task {
            await getAddons()
            self._selectedQuote = Published(
                initialValue: addonOffer?.quotes.first
            )
        }
    }

    var disableDropDown: Bool {
        addonOffer?.quotes.count ?? 0 <= 1
    }

    func getAddons() async {
        withAnimation {
            self.fetchAddonsViewState = .loading
        }

        do {
            let data = try await addonService.getAddon(contractId: contractId)
            withAnimation {
                self.addonOffer = data
                self.fetchAddonsViewState = .success
            }
        } catch let exception {
            self.fetchAddonsViewState = .error(errorMessage: exception.localizedDescription)
        }
    }

    func submitAddons() async {
        withAnimation {
            self.submittingAddonsViewState = .loading
        }
        do {
            try await addonService.submitAddon(
                quoteId: selectedQuote?.quoteId ?? "",
                addonId: selectedQuote?.addonId ?? ""
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
        let logInfoModel = AddonLogInfo(
            flow: addonSource,
            subType: selectedQuote?.addonSubtype ?? "",
            type: .travelAddon
        )
        let actionType =
            addonOffer?.currentAddon == nil ? AddonEventType.addonPurchased : AddonEventType.addonUpgraded
        log.addUserAction(
            type: .custom,
            name: actionType.rawValue,
            error: nil,
            attributes: logInfoModel.asAddonAttributes
        )
    }

    func getBreakdownDisplayItems() -> [QuoteDisplayItem] {
        if let currentAddon = addonOffer?.currentAddon {
            let currentAddonBreakdownDisplayItems = QuoteDisplayItem(
                title: currentAddon.displayNameLong,
                value: currentAddon.itemCost.premium.net?.formattedAmountPerMonth ?? "",
                crossDisplayTitle: true
            )

            let selectedAddonBreakdownDisplayItems = QuoteDisplayItem(
                title: selectedQuote?.displayNameLong ?? "",
                value: selectedQuote?.itemCost.premium.net?.formattedAmountPerMonth ?? ""
            )

            return [currentAddonBreakdownDisplayItems, selectedAddonBreakdownDisplayItems]
        } else {
            let selectedAddonBreakdownDisplayItems = QuoteDisplayItem(
                title: selectedQuote?.displayNameLong ?? "",
                value: selectedQuote?.itemCost.premium.gross?.formattedAmountPerMonth ?? ""
            )

            let discountItems: [QuoteDisplayItem] =
                selectedQuote?.itemCost.discounts.map({ .init(title: $0.displayName, value: $0.displayValue) }) ?? []

            return [selectedAddonBreakdownDisplayItems] + discountItems
        }
    }

    func compareAddonDisplayItems(newDisplayItems: [AddonDisplayItem]) -> [QuoteDisplayItem] {
        let displayItems: [QuoteDisplayItem] = newDisplayItems.map { item in
            return .init(title: item.displayTitle, value: item.displayValue)
        }
        return displayItems
    }

    func getTotalPrice() -> MonetaryAmount {
        guard let selectedQuoteNet = selectedQuote?.itemCost.premium.net else {
            return .init(amount: 0, currency: "SEK")
        }

        if let currentAddonNet = addonOffer?.currentAddon?.itemCost.premium.net {
            let amount = selectedQuoteNet.floatAmount - currentAddonNet.floatAmount
            return .init(amount: amount, currency: selectedQuoteNet.currency)
        }
        return selectedQuoteNet
    }

    func getPremium() -> Premium? {
        if addonOffer?.currentAddon != nil {
            return Premium(
                gross: nil,
                net: selectedQuote?.itemCost.premium.net
            )
        } else {
            return selectedQuote?.itemCost.premium
        }
    }
}
