import Apollo
import Foundation
import PresentableStore
import hCore
import hGraphQL

public final class ContractStore: LoadingStateStore<ContractState, ContractAction, ContractLoadingAction> {
    @Inject var fetchContractsService: FetchContractsClient
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
                send(.setTerminatedContracts(contracts: data.terminatedContracts))
                send(.setPendingContracts(contracts: data.pendingContracts))
            } catch let error {
                self.setError(error.localizedDescription, for: .fetchContracts)
            }
        case .fetch:
            await sendAsync(.fetchCrossSale)
            await sendAsync(.fetchContracts)
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
