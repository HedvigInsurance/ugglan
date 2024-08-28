import Apollo
import StoreContainer
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {
    @Inject var fetchClaimClient: hFetchClaimClient

    public override func effects(_ getState: @escaping () -> ClaimsState, _ action: ClaimsAction) async {
        switch action {
        case .fetchClaims:
            do {
                let claimData = try await self.fetchClaimClient.get()
                self.send(.setClaims(claims: claimData))
            } catch {
                self.send(.setLoadingState(action: action, state: .error(error: L10n.General.errorBody)))
            }
        default:
            break
        }
    }

    public override func reduce(_ state: ClaimsState, _ action: ClaimsAction) -> ClaimsState {
        var newState = state
        switch action {
        case .fetchClaims:
            newState.loadingStates[action] = .loading
        case let .setClaims(claims):
            newState.loadingStates.removeValue(forKey: .fetchClaims)
            newState.claims = claims
        case let .setLoadingState(action, state):
            if let state {
                newState.loadingStates[action] = state
            } else {
                newState.loadingStates.removeValue(forKey: action)
            }
        case let .setFiles(files):
            newState.files = files
        default:
            break
        }
        return newState
    }
}
