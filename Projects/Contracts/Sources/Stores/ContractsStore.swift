import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class ContractStore: LoadingStateStore<ContractState, ContractAction, ContractLoadingAction> {
    @Inject var giraffe: hGiraffe
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
                        let activeContracts = contracts.currentMember.activeContracts.map { contract in
                            Contract(contract: contract.fragments.contractFragment)

                        }
                        callback(.value(.setActiveContracts(contracts: activeContracts)))

                        let terminatedContracts = contracts.currentMember.terminatedContracts.map { contract in
                            Contract(contract: contract.fragments.contractFragment)
                        }
                        callback(.value(.setTerminatedContracts(contracts: terminatedContracts)))

                        let pendingContracts = contracts.currentMember.pendingContracts.map { contract in
                            Contract(pendingContract: contract)
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
        case .addCoInsured:
            newState.localCoInsured.forEach { coInsured in
                newState.coInsured.append(coInsured)
            }
            newState.localCoInsured = []
        case let .addLocalCoInsured(name, personalNumber):
            newState.localCoInsured.append(CoInsuredModel(name: name, SSN: personalNumber))
            newState.haveChangedCoInsured = true
        case let .removeLocalCoInsured(name, personalNumber):
            if let index = newState.coInsured.firstIndex(where: { $0.name == name && $0.SSN == personalNumber }) {
                newState.localCoInsured.remove(at: index)
            }
            newState.haveChangedCoInsured = true
        case let .removeCoInsured(name, personalNumber):
            if let index = newState.coInsured.firstIndex(where: { $0.name == name && $0.SSN == personalNumber }) {
                newState.coInsured.remove(at: index)
            }
        case .resetLocalCoInsured:
            newState.localCoInsured = []
        default:
            break
        }

        return newState
    }
}
