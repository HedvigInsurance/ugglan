import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct DataCollectionState: StateProtocol {
    var provider: String? = nil

    public init() {}
}

public enum DataCollectionAction: ActionProtocol {
    case setProvider(provider: String)
    case didIntroDecide(decision: DataCollectionIntroDecision)

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

public final class DataCollectionStore: StateStore<DataCollectionState, DataCollectionAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore

    public override func effects(
        _ getState: @escaping () -> DataCollectionState,
        _ action: DataCollectionAction
    ) -> FiniteSignal<DataCollectionAction>? {
        return nil
    }

    override public func reduce(_ state: DataCollectionState, _ action: DataCollectionAction) -> DataCollectionState {
        var newState = state

        switch action {
        case let .setProvider(provider):
            newState.provider = provider
        default:
            break
        }

        return newState
    }
}
