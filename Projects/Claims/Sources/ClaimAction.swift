import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public enum ClaimsAction: ActionProtocol, Hashable {
    case didAcceptHonestyPledge
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [Claim])
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])

    case openFreeTextChat
    case openCommonClaimDetail(commonClaim: CommonClaim)
    case openHowClaimsWork
    case openClaimDetails(claim: Claim)
}
