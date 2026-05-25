import Apollo
import PresentableStore
import SwiftUI
import hCore

public indirect enum ClaimsAction: ActionProtocol, Hashable, Sendable {
    case fetchActiveClaims
    case fetchClaimInProgress
    case fetchHistoryClaims

    case setActiveClaims(claims: [ClaimModel])
    case setHistoryClaims(claims: [ClaimModel])
    case setClaimInProgress(model: ClaimInProgressModel?)

    case setFilesForClaim(claimId: String, files: [File])
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
}

public enum ClaimsNavigationAction: ActionProtocol, Hashable {
    case hasToBeAtLeastOne
}
