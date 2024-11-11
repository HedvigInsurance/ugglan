import Foundation

public class SubmitClaimClientDemo: SubmitClaimClient {
    public init() {}

    public func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func updateContact(phoneNumber: String, context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func dateOfOccurrenceAndLocationRequest(
        context: String,
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels?
    ) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
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
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func singleItemRequest(
        context: String,
        model: FlowClamSingleItemStepModel?
    ) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func summaryRequest(context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func singleItemCheckoutRequest(context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func contractSelectRequest(contractId: String, context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func submitFileUpload(ids: [String], context: String) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }
}
