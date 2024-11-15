@MainActor
public protocol SubmitClaimClient {
    func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse
    func updateContact(phoneNumber: String, context: String) async throws -> SubmitClaimStepResponse
    func dateOfOccurrenceAndLocationRequest(context: String) async throws -> SubmitClaimStepResponse
    func submitAudioRecording(
        type: SubmitAudioRecordingType,
        fileUploaderClient: FileUploaderClient,
        context: String
    ) async throws -> SubmitClaimStepResponse
    func singleItemRequest(purchasePrice: Double?, context: String) async throws -> SubmitClaimStepResponse
    func summaryRequest(context: String) async throws -> SubmitClaimStepResponse
    func singleItemCheckoutRequest(context: String) async throws -> SubmitClaimStepResponse
    func contractSelectRequest(contractId: String, context: String) async throws -> SubmitClaimStepResponse
    func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse
    func submitFileUpload(ids: [String], context: String) async throws -> SubmitClaimStepResponse
}

public struct SubmitClaimStepResponse: Sendable {
    let claimId: String
    let context: String
    let progress: Float?
    let action: SubmitClaimsAction
}
