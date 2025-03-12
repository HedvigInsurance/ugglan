import Apollo
import PresentableStore
import SwiftUI
import hCore
import hGraphQL

public indirect enum SubmitClaimAction: ActionProtocol, Hashable, Sendable {
    case submitNewClaim(from: ClaimsOrigin)
    case setLoadingState(action: SubmitClaimAction, state: LoadingState<String>?)
}

//public enum ClaimsNavigationAction: ActionProtocol, Hashable {
//    case hasToBeAtLeastOne
//}
