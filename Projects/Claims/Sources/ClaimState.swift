import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var loadingStates: [ClaimsAction: LoadingState<String>] = [:]
    var claims: [Claim]? = nil
    var commonClaims: [CommonClaim]? = nil
    public init() {}

    private enum CodingKeys: String, CodingKey {
        case claims, commonClaims
    }

    public var hasActiveClaims: Bool {
        if let claims = claims {
            !claims.filter {
                $0.claimDetailData.status == .beingHandled || $0.claimDetailData.status == .reopened
                    || $0.claimDetailData.status == .submitted
            }
            .isEmpty
        }
        return false
    }
}
