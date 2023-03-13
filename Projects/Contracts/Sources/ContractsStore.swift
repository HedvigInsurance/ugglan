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

    func contractForId(_ id: String) -> Contract? {
        if let inBundleContract = contractBundles.flatMap({ $0.contracts })
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return contracts.first { contract in
            contract.id == id
        }
    }
}

extension ContractState {
    public var hasUnseenCrossSell: Bool {
        contractBundles.contains(where: { bundle in bundle.crossSells.contains(where: { !$0.hasBeenSeen }) })
    }

    public var hasActiveContracts: Bool {
        !contractBundles.flatMap { $0.contracts }.isEmpty
    }
}

public enum CrossSellingCoverageDetailNavigationAction: ActionProtocol {
    case detail
    case peril(peril: Perils)
    case insurableLimit(insurableLimit: InsurableLimits)
    case insuranceTerm(insuranceTerm: InsuranceTerm)
}

public enum ContractDetailNavigationAction: ActionProtocol {
    case peril(peril: Perils)
    case insurableLimit(insurableLimit: InsurableLimits)
    case document(url: URL, title: String)
    case upcomingAgreement(details: DetailAgreementsTable)
}

public enum CrossSellingFAQListNavigationAction: ActionProtocol {
    case list
    case detail(faq: FAQ)
    case chat
}

public enum ContractAction: ActionProtocol {
    // fetch everything
    case fetch

    // Fetch contracts for terminated
    case fetchContractBundles
    case fetchContracts

    case setContractBundles(activeContractBundles: [ActiveContractBundle])
    case setContracts(contracts: [Contract])
    case goToMovingFlow
    case goToFreeTextChat
    case setFocusedCrossSell(focusedCrossSell: CrossSell?)
    case openCrossSellingEmbark(name: String)
    case openCrossSellingWebUrl(url: URL)
    case openCrossSellingChat

    case crossSellingDetailEmbark(name: String)
    case crossSellWebAction(url: URL)
    case crossSellingCoverageDetailNavigation(action: CrossSellingCoverageDetailNavigationAction)
    case crossSellingFAQListNavigation(action: CrossSellingFAQListNavigationAction)
    case openCrossSellingDetail(crossSell: CrossSell)
    case hasSeenCrossSells(value: Bool)
    case closeCrossSellingSigned
    case openDetail(contractId: String)
    case openTerminatedContracts
    case didSignFocusedCrossSell
    case resetSignedCrossSells

    case contractDetailNavigationAction(action: ContractDetailNavigationAction)

    case goToTerminationFlow
    //    case goToTerminationSuccess
    case sendTermination
    case dismissTerminationFlow
}

public final class ContractStore: StateStore<ContractState, ContractAction> {
    @Inject var giraffe: hGiraffe

    public override func effects(
        _ getState: @escaping () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        switch action {
        case .fetchContractBundles:
            return giraffe.client
                .fetchActiveContractBundles(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                .valueThenEndSignal
                .map { activeContractBundles in
                    ContractAction.setContractBundles(activeContractBundles: activeContractBundles)
                }
        case .fetchContracts:
            return giraffe.client.fetchContracts(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                .valueThenEndSignal
                .filter { contracts in
                    contracts != getState().contracts
                }
                .map {
                    .setContracts(contracts: $0)
                }
        case .fetch:
            return [
                .fetchContracts,
                .fetchContractBundles,
            ]
            .emitEachThenEnd
        case .didSignFocusedCrossSell:
            return [
                .fetch
            ]
            .emitEachThenEnd
        case let .openCrossSellingDetail(crossSell):
            return [
                .setFocusedCrossSell(focusedCrossSell: crossSell)
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
        case .setContractBundles(let activeContractBundles):
            newState.hasLoadedContractBundlesOnce = true
            // Prevent infinite spinner if there are no active contracts
            guard activeContractBundles != state.contractBundles else { return newState }

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
