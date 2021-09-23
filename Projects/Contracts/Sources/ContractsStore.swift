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
    public var upcomingAgreements: [UpcomingAgreementContract] = []
    public var focusedCrossSell: CrossSell?
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
    case fetchUpcomingAgreement

    case setContractBundles(activeContractBundles: [ActiveContractBundle])
    case setContracts(contracts: [Contract])
    case setUpcomingAgreementContracts(contracts: [UpcomingAgreementContract])
    case goToMovingFlow
    case goToFreeTextChat
    case setFocusedCrossSell(focusedCrossSell: CrossSell?)
    case openCrossSellingEmbark(name: String)
    case hasSeenCrossSells(value: Bool)
    case closeCrossSellingSigned
    case openDetail(contract: Contract)
    case openTerminatedContracts

    #if compiler(<5.5)
        public func encode(to encoder: Encoder) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }

        public init(
            from decoder: Decoder
        ) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }
    #endif
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
        case .fetchUpcomingAgreement:
            return
                client.fetch(
                    query: GraphQL.UpcomingAgreementQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    ),
                    cachePolicy: .fetchIgnoringCacheData
                )
                .valueThenEndSignal
                .compactMap {
                    $0.contracts
                }
                .map {
                    $0.flatMap { UpcomingAgreementContract(contract: $0) }
                }
                .filter { upcomingAgreementContract in
                    upcomingAgreementContract != getState().upcomingAgreements
                }
                .map {
                    .setUpcomingAgreementContracts(contracts: $0)
                }
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
        case .setUpcomingAgreementContracts(let contracts):
            newState.upcomingAgreements = contracts
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
        default:
            break
        }

        return newState
    }
}
