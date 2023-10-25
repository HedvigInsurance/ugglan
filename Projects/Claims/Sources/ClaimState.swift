import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var loadingStates: [ClaimsAction: LoadingState<String>] = [:]
    var claims: [ClaimModel]? = nil

    public init() {}

    private enum CodingKeys: String, CodingKey {
        case claims
    }

    public var hasActiveClaims: Bool {
        if let claims = claims {
            return
                !claims.filter {
                    $0.status == .beingHandled || $0.status == .reopened
                        || $0.status == .submitted
                }
                .isEmpty
        }
        return false
    }
}
