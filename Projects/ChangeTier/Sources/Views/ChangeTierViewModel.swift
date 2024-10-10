import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

class ChangeTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
    @Published var viewState: ProcessingState = .loading
    @Published var displayName: String?
    @Published var exposureName: String?
    private(set) var tiers: [Tier] = []
    private var changeTierInput: ChangeTierInput
    var activationDate: Date?
    var typeOfContract: TypeOfContract?

    @Published var currentPremium: MonetaryAmount?
    var currentTier: Tier?
    private var currentDeductible: Deductible?
    var newPremium: MonetaryAmount?
    @Published var canEditTier: Bool = false

    @Published var selectedTier: Tier?
    @Published var selectedDeductible: Deductible?

    var isValid: Bool {
        let selectedTierIsSameAsCurrent = currentTier?.name == selectedTier?.name
        let selectedDeductibleIsSameAsCurrent = currentDeductible == selectedDeductible
        let isDeductibleValid = selectedDeductible != nil || selectedTier?.deductibles.isEmpty ?? false
        let isTierValid = selectedTier != nil
        let hasSelectedValues = isTierValid && isDeductibleValid

        return hasSelectedValues && !(selectedTierIsSameAsCurrent && selectedDeductibleIsSameAsCurrent)
    }

    var showDeductibleField: Bool {
        return !(selectedTier?.deductibles.isEmpty ?? true) && selectedTier != nil
    }

    init(
        changeTierInput: ChangeTierInput,
        changeTierIntentModel: ChangeTierIntentModel? = nil
    ) {
        self.changeTierInput = changeTierInput
        fetchTiers(changeTierIntentModel)
    }

    @MainActor
    func setTier(for tierName: String) {
        withAnimation {
            let newSelectedTier = tiers.first(where: { $0.name == tierName })
            if newSelectedTier != selectedTier {
                self.selectedDeductible = nil
            }
            self.selectedTier = newSelectedTier
            self.newPremium = selectedTier?.premium
        }
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        withAnimation {
            if let deductible = selectedTier?.deductibles.first(where: { $0.id == deductibleId }) {
                self.selectedDeductible = deductible
                self.newPremium = deductible.premium
            }
        }
    }

    func fetchTiers(_ existingModel: ChangeTierIntentModel?) {
        withAnimation {
            self.viewState = .loading
        }
        Task { @MainActor in
            do {
                var data: ChangeTierIntentModel!
                if let existingModel = existingModel {
                    data = existingModel
                } else {
                    data = try await service.getTier(input: changeTierInput)
                }
                self.tiers = data.tiers
                self.displayName = data.tiers.first?.productVariant?.displayName
                self.exposureName = data.tiers.first?.exposureName
                self.currentPremium = data.currentPremium

                self.currentTier = data.currentTier
                self.currentDeductible = data.currentDeductible
                self.canEditTier = data.canEditTier
                self.activationDate = data.activationDate
                self.typeOfContract = data.typeOfContract

                self.selectedTier = currentTier
                self.selectedDeductible = currentDeductible
                self.newPremium = selectedTier?.premium

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
