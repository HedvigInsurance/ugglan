import Flow
import Presentation

public protocol SubmitClaimService {
    func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse
    func updateContact(phoneNumber: String, context: String) async throws -> SubmitClaimStepResponse
}

public struct SubmitClaimStepResponse {
    let claimId: String
    let context: String
    let progress: Float?
    let action: SubmitClaimsAction
}
