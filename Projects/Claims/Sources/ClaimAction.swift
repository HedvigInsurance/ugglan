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
    case setClaims(claims: [Claim])
    case openFreeTextChat
    case openClaimDetails(claim: Claim)
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case closeClaimStatus
}
