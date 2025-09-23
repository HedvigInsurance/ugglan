import Addons
import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeTierViewModel: ObservableObject {
    let dataProvider: ChangeTierQuoteDataProvider?
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
                self.addonQuotes = relatedAddons[selectedQuote.id] ?? []
            } else {
                self.addonQuotes = []
            }
        }
    }
    @Published var selectedAddon: AddonQuote?

    @Published var excludedAddonTypes: [String] = []

    var isValid: Bool {
        let selectedTierIsSameAsCurrent = currentTier?.name == selectedTier?.name
        let selectedDeductibleIsSameAsCurrent = showDeductibleField ? currentQuote == selectedQuote : true
        let isDeductibleValid = selectedQuote != nil || selectedTier?.quotes.isEmpty ?? false
        let isTierValid = selectedTier != nil
        let hasSelectedValues = isTierValid && isDeductibleValid

        let isValid = hasSelectedValues && !(selectedTierIsSameAsCurrent && selectedDeductibleIsSameAsCurrent)
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
                selectedQuote = nil
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
    func setAddonStatus(for addonSubtype: String, enabled: Bool) {
        if self.excludedAddonTypes.contains(addonSubtype) && enabled {
            self.excludedAddonTypes.removeAll(where: { $0 == addonSubtype })
            calculateTotal()
        } else if !self.excludedAddonTypes.contains(addonSubtype) && !enabled {
            self.excludedAddonTypes.append(addonSubtype)
            calculateTotal()
        }
    }

    private func calculateTotal() {
        if let quote = selectedQuote {
            let addonIds = addonQuotes.filter({ !excludedAddonTypes.contains($0.addonSubtype) }).map { $0.id }
            if let dataProvider {
                Task {
                    do {
                        let data = try await dataProvider.getTotal(
                            selectedQuoteId: quote.id,
                            includedAddonIds: addonIds
                        )
                        withAnimation {
                            newTotalCost = data.premium
                        }
                    } catch let ex {
                        let ssss = ex
                    }
                }
            } else {
                newTotalCost = quote.newTotalCost
            }
        }
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
