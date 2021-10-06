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
