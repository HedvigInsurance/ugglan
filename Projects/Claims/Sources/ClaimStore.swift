import Apollo
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {
    @Inject var fetchClaimsClient: hFetchClaimsClient

    override public func effects(_: @escaping () -> ClaimsState, _ action: ClaimsAction) async {
        switch action {
        case .fetchActiveClaims:
            do {
                let claimData = try await fetchClaimsClient.getActiveClaims()
                await sendAsync(.setActiveClaims(claims: claimData))
            } catch {
                send(.setLoadingState(action: action, state: .error(error: L10n.General.errorBody)))
            }
        case .fetchHistoryClaims:
            do {
                let claimData = try await fetchClaimsClient.getHistoryClaims()
                await sendAsync(.setHistoryClaims(claims: claimData))
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
        case .fetchActiveClaims:
            newState.loadingStates[action] = .loading
        case .fetchHistoryClaims:
            newState.loadingStates[action] = .loading
        case let .setActiveClaims(claims):
            newState.loadingStates.removeValue(forKey: .fetchActiveClaims)
            newState.activeClaims = claims
        case let .setHistoryClaims(claims):
            newState.loadingStates.removeValue(forKey: .fetchHistoryClaims)
            newState.historyClaims = claims
        case let .setLoadingState(action, state):
            if let state {
                newState.loadingStates[action] = state
            } else {
                newState.loadingStates.removeValue(forKey: action)
            }
        case let .setFilesForClaim(claimId, files):
            newState.files[claimId] = files
        }
        return newState
    }
}
