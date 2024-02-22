import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class EditCoInsuredStore: LoadingStateStore<
    EditCoInsuredState, EditCoInsuredAction, EditCoInsuredLoadingAction
>
{
    @Inject var editCoInsuredService: EditCoInsuredService
    let coInsuredViewModel = InsuredPeopleNewScreenModel()
    let intentViewModel = IntentViewModel()

    public override func effects(
        _ getState: @escaping () -> EditCoInsuredState,
        _ action: EditCoInsuredAction
    ) -> FiniteSignal<EditCoInsuredAction>? {
        switch action {
        case let .performCoInsuredChanges(commitId):
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        try await self.editCoInsuredService.sendMidtermChangeIntentCommit(commitId: commitId)
                        self.removeLoading(for: .postCoInsured)
                        callback(.value(.fetchContracts))
                        callback(.end)
                    } catch {
                        callback(
                            .value(
                                .setLoadingState(action: action, state: .error(error: L10n.General.errorBody))
                            )
                        )
                    }
                }
                return disposeBag
            }
        default:
            break
        }
        return nil
    }

    public override func reduce(_ state: EditCoInsuredState, _ action: EditCoInsuredAction) -> EditCoInsuredState {
        var newState = state
        switch action {
        case .performCoInsuredChanges:
            setLoading(for: .postCoInsured)
        case let .setLoadingState(action, state):
            if let state {
                newState.loadingStates[action] = state
            } else {
                newState.loadingStates.removeValue(forKey: action)
            }
        default:
            break
        }

        return newState
    }
}

enum EditCoInsuredError: Error {
    case error(message: String)
}

extension EditCoInsuredError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .error(message): return message
        }
    }
}
