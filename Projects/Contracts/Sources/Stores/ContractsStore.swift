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
        case .fetchContractBundles:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.giraffe.client
                    .fetchActiveContractBundles(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                    .onValue { activeContractBundles in
                        callback(
                            .value(ContractAction.setContractBundles(activeContractBundles: activeContractBundles))
                        )
                        callback(.value(.fetchContractBundlesDone))
                    }
                    .onError { [unowned self] error in
                        if ApplicationContext.shared.isDemoMode {
                            self.removeLoading(for: .fetchContractBundles)
                        } else {
                            if !self.state.hasLoadedContractBundlesOnce {
                                self.setError(L10n.General.errorBody, for: .fetchContractBundles)
                            }
                        }
                        callback(.value(.fetchContractBundlesDone))
                    }
                return disposeBag
            }
        case .fetchContracts:
            return FiniteSignal { [unowned self] callback in
                let disposeBag = DisposeBag()
                disposeBag += self.giraffe.client
                    .fetchContracts(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                    .onValue { contracts in
                        if getState().contracts != contracts {
                            callback(.value(.setContracts(contracts: contracts)))
                        } else {
                            self.removeLoading(for: .fetchContracts)
                        }
                        callback(.value(.fetchContractsDone))
                    }
                    .onError { error in
                        if ApplicationContext.shared.isDemoMode {
                            self.removeLoading(for: .fetchContracts)
                        } else {
                            self.setError(L10n.General.errorBody, for: .fetchContracts)
                        }
                        callback(.value(.fetchContractsDone))
                    }
                return disposeBag
            }
        case .fetch:
            return [
                .fetchCrossSale,
                .fetchContracts,
                .fetchContractBundles,
            ]
                .emitEachThenEnd
            //        case .didSignFocusedCrossSell:
            //            return [
            //                .fetch
            //            ]
            //            .emitEachThenEnd
        default:
            break
        }
        return nil
    }
    
    public override func reduce(_ state: ContractState, _ action: ContractAction) -> ContractState {
        var newState = state
        switch action {
        case .fetchContractBundles:
            setLoading(for: .fetchContractBundles)
        case .fetchContracts:
            setLoading(for: .fetchContracts)
        case .setContractBundles(let activeContractBundles):
            newState.hasLoadedContractBundlesOnce = true
            removeLoading(for: .fetchContractBundles)
            guard activeContractBundles != state.contractBundles else { return newState }
            newState.contractBundles = activeContractBundles
        case let .setContracts(contracts):
            removeLoading(for: .fetchContracts)
            newState.contracts = contracts
        case .setCrossSells(let crossSells):
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
