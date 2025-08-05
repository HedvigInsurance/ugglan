import Apollo
import PresentableStore
import SwiftUI
import hCore

public struct ClaimsState: StateProtocol {
    var loadingStates: [ClaimsAction: LoadingState<String>] = [:]
    var claims: Claims?
    var files: [String: [File]] = [:]

    public init() {}

    private enum CodingKeys: String, CodingKey {
        case claims
    }

    @MainActor
    public var hasActiveClaims: Bool {
        if Dependencies.featureFlags().isClaimHistoryEnabled {
            return !(claims?.claimsActive.isEmpty ?? true)
        } else {
            if let claims = claims {
                return !claims.claims
                    .filter {
                        $0.status == .beingHandled || $0.status == .reopened
                            || $0.status == .submitted
                    }
                    .isEmpty
            }
            return false
        }
    }

    @MainActor
    public func claim(for id: String) -> ClaimModel? {
        claims?.getClaims().first(where: { $0.id == id })
    }

    @MainActor
    public func claimFromConversation(for id: String) -> ClaimModel? {
        claims?.getClaims().first(where: { $0.conversation?.id == id })
    }
}
