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
    @Inject var octopus: hOctopus
    let coInsuredViewModel = InsuredPeopleNewScreenModel()
    let intentViewModel = IntentViewModel()

    public override func effects(
        _ getState: @escaping () -> EditCoInsuredState,
        _ action: EditCoInsuredAction
    ) -> FiniteSignal<EditCoInsuredAction>? {
        switch action {
        case let .performCoInsuredChanges(commitId):
            return FiniteSignal { [unowned self] callback in
                let disposeBag = DisposeBag()
                let mutation = OctopusGraphQL.MidtermChangeIntentCommitMutation(intentId: commitId)
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        if let graphQLError = data.midtermChangeIntentCommit.userError {
                            self.setError(graphQLError.message ?? "", for: .postCoInsured)
                        } else {
                            self.removeLoading(for: .postCoInsured)
                            callback(.value(.fetchContracts))
                            callback(.end)
                        }
                    }
                    .onError({ error in
                        self.setError(error.localizedDescription, for: .postCoInsured)
                    })
                return disposeBag
            }
        default:
            break
        }
        return nil
    }

    public override func reduce(_ state: EditCoInsuredState, _ action: EditCoInsuredAction) -> EditCoInsuredState {
        switch action {
        case .performCoInsuredChanges:
            setLoading(for: .postCoInsured)
        default:
            break
        }

        return state
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
