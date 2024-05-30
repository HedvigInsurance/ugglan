import Apollo
import Foundation
import Presentation
import hCore

public final class EditCoInsuredSharedStore: LoadingStateStore<
    EditCoInsuredSharedState, EditCoInsuredSharedAction, EditCoInsuredSharedLoadingAction
>
{
    @Inject var editCoInsuredSharedService: EditCoInsuredSharedService

    public override func effects(
        _ getState: @escaping () -> EditCoInsuredSharedState,
        _ action: EditCoInsuredSharedAction
    ) async {
        switch action {
        case .fetchContracts:
            do {
                let data = try await self.editCoInsuredSharedService.fetchContracts()
                await sendAsync(.setActiveContracts(contracts: data))
            } catch {
                self.setError(L10n.General.errorBody, for: .fetchContracts)
            }
        default:
            break
        }
    }

    public override func reduce(
        _ state: EditCoInsuredSharedState,
        _ action: EditCoInsuredSharedAction
    ) -> EditCoInsuredSharedState {
        var newState = state
        switch action {
        case let .setActiveContracts(contracts):
            newState.activeContracts = contracts
        default:
            break
        }
        return newState
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
