import Apollo
import Foundation
import Presentation
import hCore
import hGraphQL

public final class ContractStore: LoadingStateStore<ContractState, ContractAction, ContractLoadingAction> {
    @Inject var fetchContractsService: FetchContractsService
    public override func effects(
        _ getState: @escaping () -> ContractState,
        _ action: ContractAction
    ) async {
        switch action {
        case .fetchCrossSale:
            do {
                let crossSells = try await self.fetchContractsService.getCrossSell()
                send(.setCrossSells(crossSells: crossSells))
            } catch let error {
                self.setError(error.localizedDescription, for: .fetchCrossSell)
            }
        case .fetchContracts:
            do {
                let data = try await self.fetchContractsService.getContracts()
                send(.setActiveContracts(contracts: data.activeContracts))
                send(.setTerminatedContracts(contracts: data.termiantedContracts))
                send(.setPendingContracts(contracts: data.pendingContracts))
                send(.fetchCompleted)
            } catch let error {
                self.setError(error.localizedDescription, for: .fetchContracts)
                send(.fetchCompleted)
            }
        case .fetch:
            send(.fetchCrossSale)
            send(.fetchContracts)
        default:
            break
        }
    }

    public override func reduce(_ state: ContractState, _ action: ContractAction) -> ContractState {
        var newState = state
        switch action {
        case .fetchContracts:
            setLoading(for: .fetchContracts)
        case let .setActiveContracts(contracts):
            newState.activeContracts = contracts
        case let .setTerminatedContracts(contracts):
            newState.terminatedContracts = contracts
        case let .setPendingContracts(contracts):
            removeLoading(for: .fetchContracts)
            newState.pendingContracts = contracts
        case let .setCrossSells(crossSells):
            newState.crossSells = crossSells
        case let .hasSeenCrossSells(value):
            newState.crossSells = newState.crossSells.map { crossSell in
                var newCrossSell = crossSell
                newCrossSell.hasBeenSeen = value
                return newCrossSell
            }
        default:
            break
        }

        return newState
    }
}
