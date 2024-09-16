import Apollo
import PresentableStore
import SwiftUI
import hCore
import hGraphQL

public indirect enum ClaimsAction: ActionProtocol, Hashable {
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [ClaimModel])
    case setFiles(files: [String: [File]])
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case refreshFiles
}

public enum ClaimsNavigationAction: ActionProtocol, Hashable {
    case hasToBeAtLeastOne
}
