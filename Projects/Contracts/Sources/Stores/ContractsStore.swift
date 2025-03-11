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
        case .fetchContracts:
            do {
                let data = try await self.fetchContractsService.getContracts()
                send(.setActiveContracts(contracts: data.activeContracts))
                send(.setTerminatedContracts(contracts: data.terminatedContracts))
                send(.setPendingContracts(contracts: data.pendingContracts))
            } catch let error {
                self.setError(error.localizedDescription, for: .fetchContracts)
            }
        default:
            break
        }
    }

    public override func reduce(_ state: ContractState, _ action: ContractAction) async -> ContractState {
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
        }

        return newState
    }
}
