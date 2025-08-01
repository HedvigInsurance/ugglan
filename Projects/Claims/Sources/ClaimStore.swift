import Apollo
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {
    @Inject var fetchClaimsClient: hFetchClaimsClient

    override public func effects(_: @escaping () -> ClaimsState, _ action: ClaimsAction) async {
        switch action {
        case .fetchClaims:
            do {
                let claimData = try await fetchClaimsClient.get()
                await sendAsync(.setClaims(claims: claimData))
            } catch {
                send(.setLoadingState(action: action, state: .error(error: L10n.General.errorBody)))
            }
        default:
            break
        }
    }

    override public func reduce(_ state: ClaimsState, _ action: ClaimsAction) async -> ClaimsState {
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
