import Foundation

public class SubmitClaimClientDemo: SubmitClaimClient {
    public init() {}

    public func startClaim(
        entrypointId _: String?,
        entrypointOptionId _: String?
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func updateContact(
        phoneNumber _: String,
        context _: String,
        model _: FlowClaimPhoneNumberStepModel
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func dateOfOccurrenceAndLocationRequest(
        context _: String,
        model _: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func submitAudioRecording(
        type _: SubmitAudioRecordingType,
        context _: String,
        currentClaimId _: String,
        model _: FlowClaimAudioRecordingStepModel
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func singleItemRequest(
        context _: String,
        model _: FlowClaimSingleItemStepModel
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func summaryRequest(
        context _: String,
        model _: SubmitClaimStep.SummaryStepModels
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func singleItemCheckoutRequest(
        context _: String,
        model _: FlowClaimSingleItemCheckoutStepModel
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func contractSelectRequest(
        contractId _: String,
        context _: String,
        model _: FlowClaimContractSelectStepModel
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func emergencyConfirmRequest(isEmergency _: Bool, context _: String) async throws -> SubmitClaimStepResponse
    {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }

    public func submitFileUpload(
        ids _: [String],
        context _: String,
        model _: FlowClaimFileUploadStepModel
    ) async throws -> SubmitClaimStepResponse {
        SubmitClaimStepResponse(
            claimId: "",
            context: "",
            progress: nil,
            step: .setFailedStep(model: .init()),
            nextStepId: ""
        )
    }
}
