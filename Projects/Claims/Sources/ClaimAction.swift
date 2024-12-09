import Apollo
import PresentableStore
import SwiftUI
import hCore
import hGraphQL

public indirect enum ClaimsAction: ActionProtocol, Hashable, Sendable {
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [ClaimModel])
    case setFilesForClaim(claimId: String, files: [File])
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case refreshFiles
}

public enum ClaimsNavigationAction: ActionProtocol, Hashable {
    case hasToBeAtLeastOne
}
