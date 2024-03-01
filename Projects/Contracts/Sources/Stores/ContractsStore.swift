import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class ContractStore: LoadingStateStore<ContractState, ContractAction, ContractLoadingAction> {
    @Inject var fetchContractsService: FetchContractsService
    public override func effects(
        _ getState: @escaping () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        switch action {
        case .fetchCrossSale:
            return FiniteSignal { [unowned self] callback in
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let crossSells = try await self.fetchContractsService.getCrossSell()
                        callback(.value(.setCrossSells(crossSells: crossSells)))
                        callback(.end)
                    } catch let error {
                        self.setError(error.localizedDescription, for: .fetchCrossSell)
                        callback(.end(error))
                    }
                }
                return disposeBag
            }
        case .fetchContracts:
            return FiniteSignal { [unowned self] callback in
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let data = try await self.fetchContractsService.getContracts()
                        callback(.value(.setActiveContracts(contracts: data.activeContracts)))
                        callback(.value(.setTerminatedContracts(contracts: data.termiantedContracts)))
                        callback(.value(.setPendingContracts(contracts: data.pendingContracts)))
                        callback(.value(.fetchCompleted))
                        callback(.end)
                    } catch let error {
                        self.setError(error.localizedDescription, for: .fetchContracts)
                        callback(.value(.fetchCompleted))
                        callback(.end(error))
                    }
                }
                return disposeBag
            }
        case .fetch:
            return [
                .fetchCrossSale,
                .fetchContracts,
            ]
            .emitEachThenEnd
        default:
            break
        }
        return nil
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
