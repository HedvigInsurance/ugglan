import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class MoveFlowStore: LoadingStateStore<MoveFlowState, MoveFlowAction, MoveFlowLoadingAction> {
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> MoveFlowState,
        _ action: MoveFlowAction
    ) -> FiniteSignal<MoveFlowAction>? {
        switch action {
        case .getMoveIntent:
            self.setLoading(for: .fetchMoveIntent)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                let mutation = OctopusGraphQL.MoveIntentCreateMutation()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .map { data in
                        if let moveIntent = data.moveIntentCreate.moveIntent?.fragments.moveIntentFragment {
                            self.removeLoading(for: .fetchMoveIntent)
                            callback(.value(.setMoveIntent(with: .init(from: moveIntent))))
                            callback(.end)
                        } else if let userError = data.moveIntentCreate.userError?.message {
                            self.setError(userError, for: .fetchMoveIntent)
                            callback(.end(MovingFlowError.serverError(message: userError)))
                        }
                    }
                    .onError({ error in
                        if let error = error as? MovingFlowError {
                            self.setError(error.localizedDescription, for: .fetchMoveIntent)
                        } else {
                            self.setError(L10n.General.errorBody, for: .fetchMoveIntent)
                        }

                    })
                return disposeBag
            }
        case .postMoveIntent:
            self.setLoading(for: .confirmMoveIntent)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                let intentId = self.state.movingFlowModel?.id ?? ""
                let mutation = OctopusGraphQL.MoveIntentCommitMutation(intentId: intentId)
                let graphQlMutation = self.octopus.client.perform(mutation: mutation)
                let minimumTime = Signal(after: 1.5).future
                disposeBag += combineLatest(graphQlMutation.resultSignal, minimumTime.resultSignal)
                    .onValue { [weak self] mutation, minimumTime in
                        if let data = mutation.value {
                            if let userError = data.moveIntentCommit.userError?.message {
                                self?.setError(userError, for: .confirmMoveIntent)
                                callback(.end(MovingFlowError.serverError(message: userError)))
                            } else {
                                self?.removeLoading(for: .confirmMoveIntent)
                                callback(.end)
                            }
                        } else if let _ = mutation.error {
                            self?.setError(L10n.General.errorBody, for: .confirmMoveIntent)
                        }
                    }
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: MoveFlowState, _ action: MoveFlowAction) -> MoveFlowState {
        var newState = state
        switch action {
        case let .setMoveIntent(model):
            newState.movingFlowModel = model
        default:
            break
        }

        return newState
    }
}

public enum MoveFlowAction: ActionProtocol {
    case getMoveIntent
    case setMoveIntent(with: MovingFlowModel)
    case postMoveIntent
    case navigation(action: MoveFlowNavigationAction)
}

public enum MoveFlowNavigationAction: ActionProtocol, Hashable {
    case openAddressFillScreen
    case openHouseFillScreen
    case openConfirmScreen
    case openProcessingView
    case openFailureScreen(error: String)
    case goToFreeTextChat
    case dismissMovingFlow
    case goBack
}

public enum MoveFlowLoadingAction: LoadingProtocol {
    case fetchMoveIntent
    case submitMoveIntent
    case confirmMoveIntent
}

public struct MoveFlowState: StateProtocol {

    public init() {}
    var movingFlowModel: MovingFlowModel?
}
