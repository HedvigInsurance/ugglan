import Apollo
import PresentableStore
import SwiftUI
import hCore

public indirect enum ClaimsAction: ActionProtocol, Hashable, Sendable {
    case fetchActiveClaims
    case fetchHistoryClaims
    case setActiveClaims(claims: [ClaimModel])
    case setHistoryClaims(claims: [ClaimModel])
    case setFilesForClaim(claimId: String, files: [File])
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case refreshFiles
}

public enum ClaimsNavigationAction: ActionProtocol, Hashable {
    case hasToBeAtLeastOne
}
