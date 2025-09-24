import Addons
import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeTierViewModel: ObservableObject {
    let dataProvider: ChangeTierQuoteDataProvider?
    @Published var dataProviderViewState: ProcessingState = .success

    private let service = ChangeTierService()
    @Published var viewState: ProcessingState = .loading
    @Published var missingQuotes = false
    @Published var displayName: String?
    @Published var exposureName: String?
    private(set) var tiers: [Tier] = []
    private(set) var changeTierInput: ChangeTierInput
    var activationDate: Date?
    var typeOfContract: TypeOfContract?

    @Published var currentTotalCost: Premium?
    @Published var newTotalCost: Premium?
    @Published var displayItemList: [QuoteDisplayItem] = []

    var currentTier: Tier?
    var currentQuote: Quote?
    var currentAddon: AddonQuote?

    // quoteId has multiple AddonQuotes - there will be only one of each type
    private var relatedAddons: [String: [AddonQuote]] = [:]
    var addonQuotes: [AddonQuote] = []
    @Published var canEditTier: Bool = false
    @Published var canEditDeductible: Bool = false

    @Published var selectedTier: Tier?
    @Published var selectedQuote: Quote? {
        didSet {
            if let selectedQuote {
                addonQuotes = relatedAddons[selectedQuote.id] ?? []
            } else {
                withAnimation {
                    addonQuotes = []
                    displayItemList = []
                    newTotalCost = nil
                }
            }
        }
    }
    @Published var selectedAddon: AddonQuote?

    @Published var excludedAddonTypes: [String] = []

    var shouldShowOldPrice: Bool {
        dataProvider != nil
    }
    var isValid: Bool {
        let selectedTierIsSameAsCurrent = currentTier?.name == selectedTier?.name
        let selectedDeductibleIsSameAsCurrent = showDeductibleField ? currentQuote == selectedQuote : true
        let isDeductibleValid = selectedQuote != nil || selectedTier?.quotes.isEmpty ?? false
        let isTierValid = selectedTier != nil
        let hasSelectedValues = isTierValid && isDeductibleValid

        let isValid =
            hasSelectedValues && !(selectedTierIsSameAsCurrent && selectedDeductibleIsSameAsCurrent)
            && dataProviderViewState == .success
        return isValid
    }

    var showDeductibleField: Bool {
        selectedTier?.quotes.filter { $0.deductableAmount != nil || $0.deductablePercentage != nil }.count ?? 0
            > 0
    }

    public init(
        changeTierInput: ChangeTierInput,
        dataProvider: ChangeTierQuoteDataProvider? = nil
    ) {
        self.changeTierInput = changeTierInput
        self.dataProvider = dataProvider
        fetchTiers()
    }

    @MainActor
    func setTier(for tierName: String) {
        let newSelectedTier = tiers.first(where: { $0.name == tierName })
        if newSelectedTier != selectedTier {
            if newSelectedTier?.quotes.count ?? 0 == 1 {
                selectedQuote = newSelectedTier?.quotes.first
                canEditDeductible = false
            } else {
                //try to set deductible from the selected quote displayTitle from newly selected tier
                if let selectedQuoteDisplayTitle = selectedQuote?.displayTitle {
                    selectedQuote = newSelectedTier?.quotes
                        .first(where: { $0.displayTitle == selectedQuoteDisplayTitle })
                } else {
                    selectedQuote = nil
                }
                canEditDeductible = true
            }
        }
        displayName =
            selectedQuote?.productVariant?.displayName ?? newSelectedTier?.quotes.first?.productVariant?
            .displayName ?? displayName
        selectedTier = newSelectedTier
        calculateTotal()
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        if let deductible = selectedTier?.quotes.first(where: { $0.id == deductibleId }) {
            selectedQuote = deductible
            calculateTotal()
        }
    }

    @MainActor
    func setAddonStatus(for addon: AddonQuote, enabled: Bool) {
        let addonSubtype = addon.addonSubtype
        if self.excludedAddonTypes.contains(addonSubtype) && enabled {
            self.excludedAddonTypes.removeAll(where: { $0 == addonSubtype })
            self.selectedAddon = addon
            calculateTotal()
        } else if !self.excludedAddonTypes.contains(addonSubtype) && !enabled {
            self.excludedAddonTypes.append(addonSubtype)
            self.selectedAddon = .init(
                displayName: L10n.tierFlowAddonNoCoverageLabel,
                displayNameLong: "",
                quoteId: L10n.tierFlowAddonNoCoverageLabel,
                addonId: L10n.tierFlowAddonNoCoverageLabel,
                addonSubtype: addonSubtype,
                displayItems: [],
                itemCost: .init(premium: .init(gross: .sek(0), net: nil), discounts: []),
                addonVariant: nil,
                documents: []
            )
            calculateTotal()
        }
    }

    func calculateTotal() {
        if let quote = selectedQuote {
            let addonIds = addonQuotes.filter({ !excludedAddonTypes.contains($0.addonSubtype) }).map { $0.id }
            if let dataProvider {
                Task { [weak self] in
                    do {
                        withAnimation {
                            self?.dataProviderViewState = .loading
                        }
                        let data = try await dataProvider.getTotal(
                            selectedQuoteId: quote.id,
                            includedAddonIds: addonIds
                        )

                        let displayItems =
                            self?.displayItems(from: data.premium, additionalDisplayItems: data.displayItems) ?? []
                        withAnimation {
                            self?.dataProviderViewState = .success
                            self?.newTotalCost = data.premium
                            self?.displayItemList = displayItems
                        }
                    } catch let ex {
                        withAnimation {
                            self?.dataProviderViewState = .error(errorMessage: ex.localizedDescription)
                            self?.newTotalCost = nil
                            self?.displayItemList = []
                        }
                    }
                }
            } else {
                newTotalCost = quote.newTotalCost
            }
        }
    }

    private func displayItems(
        from premium: hCore.Premium,
        additionalDisplayItems: [QuoteDisplayItem]
    ) -> [QuoteDisplayItem] {
        var displayItemsList = [QuoteDisplayItem]()
        //append current quote name + price
        displayItemsList.append(
            .init(
                title: self.displayName ?? "",
                value: premium.gross?.formattedAmountPerMonth ?? ""
            )
        )

        //append current quote addons + prices
        let addonsItems = addonQuotes.filter({ !excludedAddonTypes.contains($0.addonSubtype) })
            .map { quote in
                QuoteDisplayItem(
                    title: quote.addonSubtype,
                    value: quote.itemCost.premium.gross?.formattedAmountPerMonth ?? ""
                )
            }
        displayItemsList.append(contentsOf: addonsItems)

        //append rest of the items from the data provider (discounts)
        displayItemsList.append(contentsOf: additionalDisplayItems)
        return displayItemsList
    }

    func fetchTiers() {
        withAnimation {
            self.missingQuotes = false
            self.viewState = .loading
        }
        Task { @MainActor in
            do {
                let data = try await getData()
                updateCurrentTiers(data)
                updateDisplayProperties(data)
                updateSelectedValues(data)
                updatePremiumAndDeductible()

                withAnimation {
                    self.viewState = .success
                }
            } catch let exception {
                handleError(exception)
            }
        }
    }

    private func updateCurrentTiers(_ data: ChangeTierIntentModel) {
        self.currentTier = data.currentTier
        self.currentQuote = data.currentQuote
        self.relatedAddons = data.relatedAddons

        if let currentTier, !data.tiers.contains(where: { $0.name == currentTier.name }) {
            self.tiers = [currentTier] + data.tiers
        } else {
            if let currentQuote {
                var currentTierInList: Tier? = data.tiers.first(where: { $0 == currentTier })
                let tiersWithoutCurrentTier: [Tier] = data.tiers.filter { $0 != currentTier }

                let currentTierQuotes: [Quote] = [currentQuote] + (currentTierInList?.quotes ?? [])
                currentTierInList?.quotes = currentTierQuotes
                self.currentTier = currentTierInList

                if let currentTierInList {
                    self.tiers = [currentTierInList] + tiersWithoutCurrentTier
                }
            } else {
                self.tiers = data.tiers
            }
        }
    }

    private func updateDisplayProperties(_ data: ChangeTierIntentModel) {
        self.displayName = data.displayName
        self.exposureName = data.tiers.first?.exposureName
        self.currentTotalCost = data.currentQuote?.currentTotalCost
        self.activationDate = data.activationDate
        self.typeOfContract = data.typeOfContract
    }

    private func updateSelectedValues(_ data: ChangeTierIntentModel) {
        if tiers.count == 1 {
            self.selectedTier = tiers.first
            self.canEditTier = false
        } else {
            self.selectedTier = data.selectedTier ?? currentTier
            self.canEditTier = data.canEditTier
        }

        self.selectedQuote = data.selectedQuote ?? currentQuote
    }

    private func updatePremiumAndDeductible() {
        if selectedTier?.quotes.count == 1 {
            self.canEditDeductible = false
        } else {
            self.canEditDeductible = true
        }
        calculateTotal()
    }

    private func handleError(_ exception: Error) {
        if let exception = exception as? ChangeTierError {
            if case .emptyList = exception {
                withAnimation {
                    self.missingQuotes = true
                }
                return
            }
        }
        withAnimation {
            self.viewState = .error(errorMessage: exception.localizedDescription)
        }
    }

    private func getData() async throws -> ChangeTierIntentModel {
        switch changeTierInput {
        case let .contractWithSource(source):
            return try await service.getTier(input: source)
        case let .existingIntent(intent, _):
            return intent
        }
    }

    public func commitTier() {
        withAnimation {
            viewState = .loading
        }
        Task { @MainActor in
            do {
                if let id = selectedQuote?.id {
                    try await service.commitTier(
                        quoteId: id
                    )
                }
                withAnimation {
                    viewState = .success
                }
            } catch {
                withAnimation {
                    self.viewState = .error(
                        errorMessage: error.localizedDescription
                    )
                }
            }
        }
    }
}
