import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class ChangeTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
    @Published var viewState: ProcessingState = .loading
    @Published var displayName: String?
    @Published var exposureName: String?
    private(set) var tiers: [Tier] = []
    private(set) var changeTierInput: ChangeTierInput
    var activationDate: Date?
    var typeOfContract: TypeOfContract?

    @Published var currentPremium: MonetaryAmount?
    var currentTier: Tier?
    private var currentDeductible: Quote?
    var newPremium: MonetaryAmount?
    @Published var canEditTier: Bool = false

    @Published var selectedTier: Tier?
    @Published var selectedDeductible: Quote?

    var isValid: Bool {
        let selectedTierIsSameAsCurrent = currentTier?.name == selectedTier?.name
        let selectedDeductibleIsSameAsCurrent = currentDeductible == selectedDeductible
        let isDeductibleValid = selectedDeductible != nil || selectedTier?.quotes.isEmpty ?? false
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
                    self.selectedDeductible = newSelectedTier?.quotes.first
                } else {
                    self.selectedDeductible = nil
                }
            }
            self.displayName =
                selectedDeductible?.productVariant?.displayName ?? newSelectedTier?.quotes.first?.productVariant?
                .displayName ?? displayName
            self.selectedTier = newSelectedTier
            self.newPremium = selectedDeductible?.premium
        }
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        withAnimation {
            if let deductible = selectedTier?.quotes.first(where: { $0.id == deductibleId }) {
                self.selectedDeductible = deductible
                self.newPremium = deductible.premium
            }
        }
    }

    func fetchTiers() {
        withAnimation {
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
                self.currentDeductible = data.currentQuote
                self.canEditTier = data.canEditTier
                self.activationDate = data.activationDate
                self.typeOfContract = data.typeOfContract

                self.selectedTier = data.selectedTier ?? currentTier
                self.selectedDeductible = data.selectedQuote ?? currentDeductible
                self.newPremium = selectedDeductible?.premium

                withAnimation {
                    self.viewState = .success
                }
            } catch let error {
                withAnimation {
                    self.viewState = .error(errorMessage: error.localizedDescription)
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
