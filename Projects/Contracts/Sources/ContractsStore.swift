import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct ContractState: StateProtocol {
    public init() {}

    public var hasLoadedContractBundlesOnce = false
    public var contractBundles: [ActiveContractBundle] = []
    public var contracts: [Contract] = []
    public var focusedCrossSell: CrossSell?
    public var signedCrossSells: [CrossSell] = []
}

extension ContractState {
    public var hasUnseenCrossSell: Bool {
        contractBundles.contains(where: { bundle in bundle.crossSells.contains(where: { !$0.hasBeenSeen }) })
    }
}

public enum ContractAction: ActionProtocol {
    // Fetch contracts for terminated
    case fetchContractBundles
    case fetchContracts

    case setContractBundles(activeContractBundles: [ActiveContractBundle])
    case setContracts(contracts: [Contract])
    case goToMovingFlow
    case goToFreeTextChat
    case setFocusedCrossSell(focusedCrossSell: CrossSell?)
    case openCrossSellingEmbark(name: String)
    case openCrossSellingChat
    case openCrossSellingDetail(crossSell: CrossSell)
    case hasSeenCrossSells(value: Bool)
    case closeCrossSellingSigned
    case openDetail(contract: Contract)
    case openTerminatedContracts
    case didSignFocusedCrossSell
    case resetSignedCrossSells
}

public final class ContractStore: StateStore<ContractState, ContractAction> {
    @Inject var client: ApolloClient

    public override func effects(
        _ getState: @escaping () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        switch action {
        case .fetchContractBundles:
            return
                client.fetchActiveContractBundles(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                .valueThenEndSignal
                .filter { activeContractBundles in
                    activeContractBundles != getState().contractBundles
                }
                .map { activeContractBundles in
                    ContractAction.setContractBundles(activeContractBundles: activeContractBundles)
                }
        case .fetchContracts:
            return
                client.fetchContracts(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                .valueThenEndSignal
                .filter { contracts in
                    contracts != getState().contracts
                }
                .map {
                    .setContracts(contracts: $0)
                }
        case .didSignFocusedCrossSell:
            return [
                .fetchContracts,
                .fetchContractBundles,
            ]
            .emitEachThenEnd
        case let .openCrossSellingDetail(crossSell):
            return [
                .setFocusedCrossSell(focusedCrossSell: crossSell)
            ].emitEachThenEnd
        default:
            break
        }
        return nil
    }

    public override func reduce(_ state: ContractState, _ action: ContractAction) -> ContractState {
        var newState = state
        switch action {
        case .setContractBundles(let activeContractBundles):
            newState.hasLoadedContractBundlesOnce = true
            newState.contractBundles = activeContractBundles
        case .setContracts(let contracts):
            newState.contracts = contracts
        case let .hasSeenCrossSells(value):
            newState.contractBundles = newState.contractBundles.map { bundle in
                var newBundle = bundle

                newBundle.crossSells = newBundle.crossSells.map { crossSell in
                    var newCrossSell = crossSell
                    newCrossSell.hasBeenSeen = value
                    return newCrossSell
                }

                return newBundle
            }
        case let .setFocusedCrossSell(focusedCrossSell):
            newState.focusedCrossSell = focusedCrossSell
        case .didSignFocusedCrossSell:
            newState.focusedCrossSell = nil
            newState.signedCrossSells = [newState.signedCrossSells, [newState.focusedCrossSell].compactMap { $0 }]
                .flatMap { $0 }
        case .resetSignedCrossSells:
            newState.signedCrossSells = []
        default:
            break
        }

        return newState
    }
}
