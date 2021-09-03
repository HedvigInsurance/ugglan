import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct ContractState: StateProtocol {
    public init() {}

    var contractBundles: [ActiveContractBundle] = []
    var contracts: [Contract] = []
    var upcomingAgreements: [UpcomingAgreementContract] = []
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
        _ getState: () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        switch action {
        case .fetchContractBundles:
            return
                client.fetch(
                    query: GraphQL.ActiveContractBundlesQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    ),
                    cachePolicy: .fetchIgnoringCacheData
                )
                .map { data in
                    data.activeContractBundles.map { ActiveContractBundle(bundle: $0) }
                }
                .map { activeContractBundles in
                    ContractAction.setContractBundles(activeContractBundles: activeContractBundles)
                }
                .valueThenEndSignal
        case .setContractBundles:
            break
        case .goToMovingFlow:
            break
        case .fetchContracts:
            return
                client.fetch(
                    query: GraphQL.ContractsQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    ),
                    cachePolicy: .fetchIgnoringCacheData
                )
                .compactMap { $0.contracts }
                .map {
                    $0.flatMap { Contract(contract: $0) }
                }
                .map {
                    .setContracts(contracts: $0)
                }
                .valueThenEndSignal
        case .setContracts:
            break
        case .goToFreeTextChat:
            break
        case .fetchUpcomingAgreement:
            return
                client.fetch(
                    query: GraphQL.UpcomingAgreementQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    ),
                    cachePolicy: .fetchIgnoringCacheData
                )
                .compactMap {
                    $0.contracts
                }
                .map {
                    $0.flatMap { UpcomingAgreementContract(contract: $0) }
                }
                .map {
                    .setUpcomingAgreementContracts(contracts: $0)
                }
                .valueThenEndSignal
        case .setUpcomingAgreementContracts:
            break
        }
        return nil
    }

    public override func reduce(_ state: ContractState, _ action: ContractAction) -> ContractState {
        var newState = state
        switch action {
        case .fetchContractBundles:
            break
        case .setContractBundles(let activeContractBundles):
            newState.contractBundles = activeContractBundles
        case .goToMovingFlow:
            break
        case .fetchContracts:
            break
        case .setContracts(let contracts):
            newState.contracts = contracts
        case .goToFreeTextChat:
            break
        case .fetchUpcomingAgreement:
            break
        case .setUpcomingAgreementContracts(let contracts):
            newState.upcomingAgreements = contracts
        }

        return newState
    }
}
