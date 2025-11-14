import Apollo
import PresentableStore
import SwiftUI
import hCore

public struct ClaimsState: StateProtocol {
    var loadingStates: [ClaimsAction: LoadingState<String>] = [:]
    var activeClaims: [ClaimModel]?
    var historyClaims: [ClaimModel]?
    var files: [String: [File]] = [:]

    public init() {}

    @MainActor
    public var hasActiveClaims: Bool {
        if let claims = activeClaims {
            return
                !claims
                .filter {
                    $0.status == .beingHandled || $0.status == .reopened
                        || $0.status == .submitted
                }
                .isEmpty
        }
        return false
    }

    public func getClaimFor(id: String) -> ClaimModel? {
        activeClaims?.first(where: { $0.id == id })
    }
}
