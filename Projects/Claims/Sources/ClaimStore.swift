import Apollo
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {
    @Inject var fetchClaimsClient: hFetchClaimsClient

    public override func effects(_ getState: @escaping () -> ClaimsState, _ action: ClaimsAction) async {
        switch action {
        case .fetchClaims:
            do {
                let claimData = try await self.fetchClaimsClient.get()
                await self.sendAsync(.setClaims(claims: claimData))
            } catch {
                self.send(.setLoadingState(action: action, state: .error(error: L10n.General.errorBody)))
            }
        default:
            break
        }
    }

    public override func reduce(_ state: ClaimsState, _ action: ClaimsAction) async -> ClaimsState {
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
        case let .setFilesForClaim(claimId, files):
            newState.files[claimId] = files
        default:
            break
        }
        return newState
    }
}
