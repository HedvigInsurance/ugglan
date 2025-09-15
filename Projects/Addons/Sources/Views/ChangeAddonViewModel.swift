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
        let currentAddonBreakdownDisplayItems = QuoteDisplayItem(
            title: addonOffer?.currentAddon?.displayNameLong ?? "",
            value: addonOffer?.currentAddon?.price.net?.formattedAmountPerMonth ?? ""
        )

        let selectedAddonBreakdownDisplayItems = QuoteDisplayItem(
            title: selectedQuote?.displayNameLong ?? "",
            value: selectedQuote?.price.net?.formattedAmountPerMonth ?? ""
        )

        return [currentAddonBreakdownDisplayItems, selectedAddonBreakdownDisplayItems]
    }

    func compareAddonDisplayItems(
        currentDisplayItems: [AddonDisplayItem],
        newDisplayItems: [AddonDisplayItem]
    ) -> [QuoteDisplayItem] {
        let displayItems: [QuoteDisplayItem] = newDisplayItems.map { item in
            if let matchingDisplayItem = currentDisplayItems.first(where: { $0.displayTitle == item.displayTitle }) {
                return .init(
                    title: item.displayTitle,
                    value: item.displayValue,
                    displayValueOld: matchingDisplayItem.displayValue
                )
            }
            return .init(title: item.displayTitle, value: item.displayValue)
        }
        return displayItems
    }

    func getTotalPrice(currentPrice: MonetaryAmount?, newPrice: MonetaryAmount?) -> MonetaryAmount {
        let diffValue: Float = {
            if let currentPrice, let newPrice {
                return newPrice.value - currentPrice.value
            } else {
                return 0
            }
        }()

        let totalPrice = (currentPrice != nil) ? .init(amount: String(diffValue), currency: "SEK") : newPrice
        return totalPrice ?? .init(amount: 0, currency: "SEK")
    }
}
