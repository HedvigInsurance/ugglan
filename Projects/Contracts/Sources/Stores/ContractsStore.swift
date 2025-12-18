import Apollo
import Foundation
import PresentableStore
import hCore

public final class ContractStore: LoadingStateStore<ContractState, ContractAction, ContractLoadingAction> {
    @Inject var fetchContractsService: FetchContractsClient
    override public func effects(
        _: @escaping () -> ContractState,
        _ action: ContractAction
    ) async {
        switch action {
        case .fetchContracts:
            do {
                let data = try await fetchContractsService.getContracts()
                await sendAsync(.setActiveContracts(contracts: data.activeContracts))
                await sendAsync(.setTerminatedContracts(contracts: data.terminatedContracts))
                await sendAsync(.setPendingContracts(contracts: data.pendingContracts))
            } catch {
                setError(error.localizedDescription, for: .fetchContracts)
            }
        default:
            break
        }
    }

    override public func reduce(_ state: ContractState, _ action: ContractAction) async -> ContractState {
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
