import Apollo
import EditCoInsuredShared
import Foundation
import Presentation
import hCore

public final class EditCoInsuredStore: LoadingStateStore<
    EditCoInsuredState, EditCoInsuredAction, EditCoInsuredLoadingAction
>
{
    @Inject var editCoInsuredService: EditCoInsuredClient
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
    case serviceError(message: String)
    case missingSSN
    case otherError
}

extension EditCoInsuredError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .serviceError(message): return message
        case .missingSSN:
            return L10n.coinsuredSsnNotFound
        case .otherError:
            return L10n.General.errorBody
        }
    }
}
