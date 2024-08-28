import Apollo
import StoreContainer
import SwiftUI
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var loadingStates: [ClaimsAction: LoadingState<String>] = [:]
    var claims: [ClaimModel]? = nil
    var files: [String: [File]] = [:]

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

    public func claim(for id: String) -> ClaimModel? {
        self.claims?.first(where: { $0.id == id })
    }
}
