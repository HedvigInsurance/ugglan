import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

public enum ClaimsAction: ActionProtocol, Hashable {
    case didAcceptHonestyPledge
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    //    case setClaims(claims: [Claim])
    case setClaims(claims: LoadingWrapper<[Claim], String>)
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])

    case openFreeTextChat
    case openCommonClaimDetail(commonClaim: CommonClaim)
    case openHowClaimsWork
    case openClaimDetails(claim: Claim)
    case odysseyRedirect(url: String)
}
