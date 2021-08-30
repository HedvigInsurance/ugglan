import Apollo
import Flow
import Presentation
import hCore
import hGraphQL

public struct ContractState: StateProtocol {
    public init() {}

    var contractBundles: [ActiveContractBundle] = []
}

public enum ContractAction: ActionProtocol {
    case fetchContractBundles
    case setContractBundles(activeContractBundles: [ActiveContractBundle])
    case goToMovingFlow

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
            return client.fetch(query: GraphQL.ActiveContractBundlesQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
                                cachePolicy: .fetchIgnoringCacheData)
                .map { data in
                    data.activeContractBundles.map { ActiveContractBundle(bundle: $0) }
                }
                .map { activeContractBundles in
                    ContractAction.setContractBundles(activeContractBundles: activeContractBundles)
                }
                .valueThenEndSignal
        case .setContractBundles(let activeContractBundles):
            break
        case .goToMovingFlow:
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
        }

        return newState
    }
}
