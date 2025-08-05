import Apollo
import PresentableStore
import SwiftUI
import hCore

public indirect enum ClaimsAction: ActionProtocol, Hashable, Sendable {
    case fetchClaims
    case setClaims(claims: Claims)
    case setFilesForClaim(claimId: String, files: [File])
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case refreshFiles
}

public enum ClaimsNavigationAction: ActionProtocol, Hashable {
    case hasToBeAtLeastOne
}
