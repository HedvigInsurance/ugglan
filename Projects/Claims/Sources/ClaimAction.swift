import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public indirect enum ClaimsAction: ActionProtocol, Hashable {
    case didAcceptHonestyPledge
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [ClaimModel])
    case openFreeTextChat
    case openClaimDetails(claim: ClaimModel)
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case closeClaimStatus
    case navigation(action: ClaimsNavigationAction)

}

public enum ClaimsNavigationAction: ActionProtocol, Hashable {
    case openFile(file: File)
}
