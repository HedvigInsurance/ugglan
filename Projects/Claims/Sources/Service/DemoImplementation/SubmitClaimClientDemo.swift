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

    public func updateContact(
        phoneNumber: String,
        context: String,
        model: FlowClaimPhoneNumberStepModel?
    ) async throws -> SubmitClaimStepResponse {
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
        context: String,
        currentClaimId: String,
        model: FlowClaimAudioRecordingStepModel?
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
        model: FlowClaimSingleItemStepModel?
    ) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func summaryRequest(
        context: String,
        model: SubmitClaimStep.SummaryStepModels?
    ) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func singleItemCheckoutRequest(
        context: String,
        model: FlowClaimSingleItemCheckoutStepModel?
    ) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }

    public func contractSelectRequest(
        contractId: String,
        context: String,
        model: FlowClaimContractSelectStepModel?
    ) async throws -> SubmitClaimStepResponse {
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

    public func submitFileUpload(
        ids: [String],
        context: String,
        model: FlowClaimFileUploadStepModel?
    ) async throws -> SubmitClaimStepResponse {
        return SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init(id: ""))
        )
    }
}
