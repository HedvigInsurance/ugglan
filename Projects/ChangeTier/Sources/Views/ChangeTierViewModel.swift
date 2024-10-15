import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class ChangeTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
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
        let selectedDeductibleIsSameAsCurrent = currentQuote == selectedQuote
        let isDeductibleValid = selectedQuote != nil || selectedTier?.quotes.isEmpty ?? false
        let isTierValid = selectedTier != nil
        let hasSelectedValues = isTierValid && isDeductibleValid

        return hasSelectedValues && !(selectedTierIsSameAsCurrent && selectedDeductibleIsSameAsCurrent)
    }

    var showDeductibleField: Bool {
        return !(selectedTier?.quotes.isEmpty ?? true) && selectedTier != nil
    }

    public init(
        changeTierInput: ChangeTierInput
    ) {
        self.changeTierInput = changeTierInput
        fetchTiers()
    }

    @MainActor
    func setTier(for tierName: String) {
        withAnimation {
            let newSelectedTier = tiers.first(where: { $0.name == tierName })
            if newSelectedTier != selectedTier {
                if newSelectedTier?.quotes.count ?? 0 == 1 {
                    self.selectedQuote = newSelectedTier?.quotes.first
                    self.canEditDeductible = false
                } else {
                    self.selectedQuote = nil
                    self.canEditDeductible = true
                }
            }
            self.displayName =
                selectedQuote?.productVariant?.displayName ?? newSelectedTier?.quotes.first?.productVariant?
                .displayName ?? displayName
            self.selectedTier = newSelectedTier
            self.newPremium = selectedQuote?.premium
        }
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        withAnimation {
            if let deductible = selectedTier?.quotes.first(where: { $0.id == deductibleId }) {
                self.selectedQuote = deductible
                self.newPremium = deductible.premium
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
                self.tiers = data.tiers
                self.displayName = data.displayName
                self.exposureName = data.tiers.first?.exposureName
                self.currentPremium = data.currentPremium
                self.currentTier = data.currentTier
                self.currentQuote = data.currentQuote
                self.activationDate = data.activationDate
                self.typeOfContract = data.typeOfContract

                if tiers.count == 1 {
                    self.selectedTier = tiers.first
                    self.canEditTier = false
                } else {
                    self.selectedTier = data.selectedTier ?? currentTier
                    self.canEditTier = data.canEditTier
                }

                if selectedTier?.quotes.count == 1 {
                    self.selectedQuote = selectedTier?.quotes.first
                    self.canEditDeductible = false
                } else {
                    self.selectedQuote = data.selectedQuote ?? currentQuote
                    self.canEditDeductible = true
                }

                self.newPremium = selectedQuote?.premium

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
                if let id = selectedTier?.id {
                    try await service.commitTier(
                        quoteId: id
                    )
                }
                withAnimation {
                    viewState = .success
                }
            } catch let error {
                withAnimation {
                    self.viewState = .error(
                        errorMessage: error.localizedDescription ?? L10n.tierFlowCommitProcessingErrorDescription
                    )
                }
            }
        }
    }
}
