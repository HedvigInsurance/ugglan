import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class ContractStore: LoadingStateStore<ContractState, ContractAction, ContractLoadingAction> {
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        switch action {
        case .fetchCrossSale:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.CrossSellsQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue({ data in
                        let crossSells = data.currentMember.fragments.crossSellFragment.crossSells.compactMap({
                            CrossSell($0)
                        })
                        callback(.value(.setCrossSells(crossSells: crossSells)))
                    })
                return disposeBag
            }
        case .fetchContracts:
            return FiniteSignal { [unowned self] callback in
                let disposeBag = DisposeBag()
                let query = OctopusGraphQL.ContractBundleQuery()
                disposeBag += self.octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
                    .onValue { contracts in
                        let firstName = contracts.currentMember.firstName
                        let lastName = contracts.currentMember.lastName
                        let ssn = contracts.currentMember.ssn
                        let activeContracts = contracts.currentMember.activeContracts.map { contract in
                            Contract(
                                contract: contract.fragments.contractFragment,
                                firstName: firstName,
                                lastName: lastName,
                                ssn: ssn
                            )
                        }
                        callback(.value(.setActiveContracts(contracts: activeContracts)))

                        let terminatedContracts = contracts.currentMember.terminatedContracts.map { contract in
                            Contract(
                                contract: contract.fragments.contractFragment,
                                firstName: firstName,
                                lastName: lastName,
                                ssn: ssn
                            )
                        }
                        callback(.value(.setTerminatedContracts(contracts: terminatedContracts)))

                        let pendingContracts = contracts.currentMember.pendingContracts.map { contract in
                            Contract(
                                pendingContract: contract,
                                firstName: firstName,
                                lastName: lastName,
                                ssn: ssn
                            )
                        }
                        callback(.value(.setPendingContracts(contracts: pendingContracts)))
                        callback(.value(.fetchCompleted))
                    }
                    .onError { error in
                        if ApplicationContext.shared.isDemoMode {
                            self.removeLoading(for: .fetchContracts)
                        } else {
                            self.setError(L10n.General.errorBody, for: .fetchContracts)
                        }
                        callback(.value(.fetchCompleted))
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
