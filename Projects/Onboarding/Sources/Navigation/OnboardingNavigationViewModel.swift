import AppStateContainer
import Contracts
import EditStakeholders
import SwiftUI
import hCore
import hCoreUI

@MainActor
class OnboardingNavigationViewModel: ObservableObject {
    let router = NavigationRouter()
    let onboardingService = OnboardingService()
    let editStakeholdersVm: EditStakeholdersViewModel
    @Published var steps: [OnboardingStep] = [
        .welcome
    ]

    @Published var missingPetChipIdInput: MissingPetChipIdInput?

    init() {
        let contractStore: ContractStore = globalAppStateContainer.get()
        editStakeholdersVm = .init(existingStakeholders: contractStore)
    }

    func advance(after step: OnboardingStep) {
        guard let index = steps.firstIndex(where: { $0.matches(step) }), index + 1 < steps.count else {
            router.dismiss()
            return
        }
        router.push(steps[index + 1])
    }
}

// MARK: - Co-insured & co-owner steps
extension OnboardingNavigationViewModel {
    /// A stakeholder was added for `contractId` — clear `missingData` on that contract in
    /// the matching step, so the screen (which reads its contracts from `steps`) shows the
    /// added checkmark.
    func markStakeholderAdded(contractId: String, type: StakeholderType) {
        steps = steps.map { step in
            switch (type, step) {
            case let (.coInsured, .coInsured(contracts)):
                return .coInsured(contracts: contracts.markingAdded(contractId: contractId))
            case let (.coOwner, .coOwners(contracts)):
                return .coOwners(contracts: contracts.markingAdded(contractId: contractId))
            default:
                return step
            }
        }
    }
}

// MARK: - Pet chip id step
extension OnboardingNavigationViewModel {
    /// A pet chip id was added for `contractId` — clear `missingData` on that contract
    /// in the step, so the screen (which reads its contracts from `steps`) shows the
    /// added checkmark.
    func markPetChipIdAdded(contractId: String) {
        steps = steps.map { step in
            guard case let .petChipIds(contracts) = step else { return step }
            return .petChipIds(contracts: contracts.markingAdded(contractId: contractId))
        }
    }
}

extension [OnboardingContract] {
    fileprivate func markingAdded(contractId: String) -> [OnboardingContract] {
        map { contract in
            var contract = contract
            if contract.id == contractId { contract.missingData = false }
            return contract
        }
    }
}
