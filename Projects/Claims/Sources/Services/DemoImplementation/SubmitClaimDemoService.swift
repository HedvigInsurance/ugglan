import Foundation

public class SubmitClaimDemoService: SubmitClaimService {
    public init() {}

    public func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            action: .startClaimRequest(entrypointId: nil, entrypointOptionId: nil)
        )
    }

    public func updateContact(phoneNumber: String, context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            action: .phoneNumberRequest(phoneNumber: "")
        )
    }

    public func dateOfOccurrenceAndLocationRequest(context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            action: .dateOfOccurrenceAndLocationRequest
        )
    }

    public func submitAudioRecording(
        type: SubmitAudioRecordingType,
        fileUploaderClient: FileUploaderClient,
        context: String
    ) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            action: .submitAudioRecording(type: .audio(url: URL(string: "")!))
        )
    }

    public func singleItemRequest(purchasePrice: Double?, context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            action: .singleItemRequest(purchasePrice: 0)
        )
    }

    public func summaryRequest(context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(claimId: "", context: "", progress: nil, action: .summaryRequest)
    }

    public func singleItemCheckoutRequest(context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(claimId: "", context: "", progress: nil, action: .singleItemCheckoutRequest)
    }

    public func contractSelectRequest(contractId: String, context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            action: .contractSelectRequest(contractId: "")
        )
    }

    public func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            action: .emergencyConfirmRequest(isEmergency: true)
        )
    }

    public func submitFileUpload(ids: [String], context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(claimId: "", context: "", progress: nil, action: .submitFileUpload(ids: []))
    }
}
