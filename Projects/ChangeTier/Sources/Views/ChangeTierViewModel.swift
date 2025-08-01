import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeTierViewModel: ObservableObject {
    private let service = ChangeTierService()
    @Published var viewState: ProcessingState = .loading
    @Published var missingQuotes = false
    @Published var displayName: String?
    @Published var exposureName: String?
    private(set) var tiers: [Tier] = []
    private(set) var changeTierInput: ChangeTierInput
    var activationDate: Date?
    var typeOfContract: TypeOfContract?

    @Published var currentPremium: MonetaryAmount?
    var currentTier: Tier?
    private var currentQuote: Quote?
    var newPremium: MonetaryAmount?
    @Published var canEditTier: Bool = false
    @Published var canEditDeductible: Bool = false

    @Published var selectedTier: Tier?
    @Published var selectedQuote: Quote?

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
        changeTierInput: ChangeTierInput
    ) {
        self.changeTierInput = changeTierInput
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
        newPremium = selectedQuote?.basePremium
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        if let deductible = selectedTier?.quotes.first(where: { $0.id == deductibleId }) {
            selectedQuote = deductible
            newPremium = deductible.basePremium
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
                self.currentTier = data.currentTier
                self.currentQuote = data.currentQuote

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
                self.displayName = data.displayName
                self.exposureName = data.tiers.first?.exposureName
                self.currentPremium = data.currentPremium
                self.activationDate = data.activationDate
                self.typeOfContract = data.typeOfContract

                if tiers.count == 1 {
                    self.selectedTier = tiers.first
                    self.canEditTier = false
                } else {
                    self.selectedTier = data.selectedTier ?? currentTier
                    self.canEditTier = data.canEditTier
                }

                self.selectedQuote = data.selectedQuote ?? currentQuote
                if selectedTier?.quotes.count == 1 {
                    self.canEditDeductible = false
                } else {
                    self.canEditDeductible = true
                }

                self.newPremium = selectedQuote?.basePremium

                withAnimation {
                    self.viewState = .success
                }
            } catch let exception {
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
