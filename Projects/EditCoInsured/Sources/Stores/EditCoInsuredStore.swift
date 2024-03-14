import Apollo
import Foundation
import Presentation
import hCore

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
    ) async {
        switch action {
        case let .performCoInsuredChanges(commitId):
            do {
                try await self.editCoInsuredService.sendMidtermChangeIntentCommit(commitId: commitId)
                self.removeLoading(for: .postCoInsured)
                send(.fetchContracts)
                AskForRating().askForReview()
            } catch {
                self.setError(L10n.General.errorBody, for: .postCoInsured)
            }
        default:
            break
        }
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
    case graphQLError(message: String)
    case missingSSN
    case otherError
}

extension EditCoInsuredError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .graphQLError(message): return message
        case .missingSSN:
            return L10n.coinsuredSsnNotFound
        case .otherError:
            return L10n.General.errorBody
        }
    }
}
