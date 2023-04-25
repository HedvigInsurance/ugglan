import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var claims: LoadingWrapper<[Claim], String> = .loading
    //    var claims: [Claim]? = nil
    var commonClaims: [CommonClaim]? = nil
    public init() {}

    private enum CodingKeys: String, CodingKey {
        case claims, commonClaims
    }

    public var hasActiveClaims: Bool {
        switch claims {
        case let .success(claims):
            return
                !claims.filter {
                    $0.claimDetailData.status == .beingHandled || $0.claimDetailData.status == .reopened
                        || $0.claimDetailData.status == .submitted
                }
                .isEmpty
        default:
            return false
        }
    }
}
