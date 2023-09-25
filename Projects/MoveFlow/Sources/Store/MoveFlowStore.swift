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
        case .requestMoveIntent:
            self.setLoading(for: .requestMoveIntent)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                if let intentId = self.state.movingFlowModel?.id,
                    let fromAddressId = self.state.movingFromAddressModel?.id
                {
                    let newAddressModel = self.state.newAddressModel.toGraphQLInput(
                        from: fromAddressId,
                        with: self.state.selectedHousingType
                    )
                    let mutation = OctopusGraphQL.MoveIntentRequestMutation(
                        intentId: intentId,
                        input: newAddressModel
                    )
                    disposeBag += self.octopus.client.perform(mutation: mutation)
                        .onValue({ [weak self] value in
                            if let fragment = value.moveIntentRequest.moveIntent?.fragments.moveIntentFragment {
                                let model = MovingFlowModel(from: fragment)
                                self?.send(.setMoveIntent(with: model))
                                self?.send(.navigation(action: .openConfirmScreen))
                                self?.removeLoading(for: .requestMoveIntent)
                            } else if let error = value.moveIntentRequest.userError?.message {
                                self?.setError(error, for: .requestMoveIntent)
                            }
                        })
                        .onError({ [weak self] error in
                            self?.setError(L10n.generalError, for: .requestMoveIntent)
                        })
                }
                return disposeBag
            }
        case .confirmMoveIntent:
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
            newState.movingFromAddressModel = MovingFromAddressModel(id: model.currentHomeAddresses.first?.id ?? "")
            newState.movingFlowModel = model
        case let .setMovingFromAddress(model):
            newState.movingFromAddressModel = model
        case let .setNewAddress(model):
            newState.newAddressModel = model
            switch newState.selectedHousingType {
            case .apartmant, .rental:
                send(.requestMoveIntent)
            case .house:
                send(.navigation(action: .openHouseFillScreen))
            }
        case let .setHousingType(housingType):
            newState.selectedHousingType = housingType
        default:
            break
        }
        return newState
    }
}

public enum MoveFlowAction: ActionProtocol {
    case getMoveIntent
    case setMoveIntent(with: MovingFlowModel)
    case setHousingType(with: HousingType)
    case requestMoveIntent

    case setMovingFromAddress(with: MovingFromAddressModel)
    case setNewAddress(with: NewAddressModel)

    case confirmMoveIntent
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
    case requestMoveIntent
    case confirmMoveIntent
}

public struct MoveFlowState: StateProtocol {

    public init() {}
    @Transient(defaultValue: .apartmant) var selectedHousingType: HousingType
    @OptionalTransient var movingFlowModel: MovingFlowModel?
    @OptionalTransient var movingFromAddressModel: MovingFromAddressModel?
    @Transient(defaultValue: NewAddressModel()) var newAddressModel: NewAddressModel
}
