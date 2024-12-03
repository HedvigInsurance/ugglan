import hCore
import hGraphQL

@MainActor
class SubmitClaimService {
    @Inject var client: SubmitClaimClient

    func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse {
        log.info(
            "\(SubmitClaimService.self): start claim for entrypointId: \(entrypointId ?? "--"), entrypointOptionId: \(entrypointOptionId ?? "--")"
        )
        let data = try await client.startClaim(entrypointId: entrypointId, entrypointOptionId: entrypointOptionId)
        return data
    }

    func updateContact(
        phoneNumber: String,
        context: String,
        model: FlowClaimPhoneNumberStepModel
    ) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): update contact for phoneNumber: \(phoneNumber)")
        let data = try await client.updateContact(phoneNumber: phoneNumber, context: context, model: model)
        return data
    }

    func dateOfOccurrenceAndLocationRequest(
        context: String,
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels
    ) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): dateOfOccurrenceAndLocationRequest \(model)")
        let data = try await client.dateOfOccurrenceAndLocationRequest(context: context, model: model)
        return data
    }

    func submitAudioRecording(
        type: SubmitAudioRecordingType,
        context: String,
        currentClaimId: String,
        model: FlowClaimAudioRecordingStepModel
    ) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): submitAudioRecording")
        let data = try await client.submitAudioRecording(
            type: type,
            context: context,
            currentClaimId: currentClaimId,
            model: model
        )
        return data
    }

    func singleItemRequest(
        context: String,
        model: FlowClaimSingleItemStepModel
    ) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): singleItemRequest \(model)")
        let data = try await client.singleItemRequest(context: context, model: model)
        return data
    }

    func summaryRequest(
        context: String,
        model: SubmitClaimStep.SummaryStepModels
    ) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): summaryRequest")
        let data = try await client.summaryRequest(context: context, model: model)
        return data
    }

    func singleItemCheckoutRequest(
        context: String,
        model: FlowClaimSingleItemCheckoutStepModel
    ) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): singleItemCheckoutRequest \(model)")
        let data = try await client.singleItemCheckoutRequest(context: context, model: model)
        return data
    }

    func contractSelectRequest(
        contractId: String,
        context: String,
        model: FlowClaimContractSelectStepModel
    ) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): contractSelectRequest \(contractId)")
        let data = try await client.contractSelectRequest(contractId: contractId, context: context, model: model)
        return data
    }

    func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): emergencyConfirmRequest \(isEmergency)")
        let data = try await client.emergencyConfirmRequest(isEmergency: isEmergency, context: context)
        return data
    }

    func submitFileUpload(
        ids: [String],
        context: String,
        model: FlowClaimFileUploadStepModel
    ) async throws -> SubmitClaimStepResponse {
        log.info("\(SubmitClaimService.self): submitFileUpload \(ids)")
        let data = try await client.submitFileUpload(ids: ids, context: context, model: model)
        return data
    }
}

@MainActor
public protocol SubmitClaimClient {
    func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse
    func updateContact(
        phoneNumber: String,
        context: String,
        model: FlowClaimPhoneNumberStepModel
    ) async throws -> SubmitClaimStepResponse
    func dateOfOccurrenceAndLocationRequest(
        context: String,
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels
    ) async throws -> SubmitClaimStepResponse
    func submitAudioRecording(
        type: SubmitAudioRecordingType,
        context: String,
        currentClaimId: String,
        model: FlowClaimAudioRecordingStepModel
    ) async throws -> SubmitClaimStepResponse
    func singleItemRequest(
        context: String,
        model: FlowClaimSingleItemStepModel
    ) async throws -> SubmitClaimStepResponse
    func summaryRequest(
        context: String,
        model: SubmitClaimStep.SummaryStepModels
    ) async throws -> SubmitClaimStepResponse
    func singleItemCheckoutRequest(
        context: String,
        model: FlowClaimSingleItemCheckoutStepModel
    ) async throws -> SubmitClaimStepResponse
    func contractSelectRequest(
        contractId: String,
        context: String,
        model: FlowClaimContractSelectStepModel
    ) async throws -> SubmitClaimStepResponse
    func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse
    func submitFileUpload(
        ids: [String],
        context: String,
        model: FlowClaimFileUploadStepModel
    ) async throws -> SubmitClaimStepResponse
}

public struct SubmitClaimStepResponse: Sendable {
    let claimId: String
    let context: String
    let progress: Float?
    let step: SubmitClaimStep
    let nextStepId: String
}

public enum SubmitClaimStep: Equatable, Sendable {
    public struct DateOfOccurrencePlusLocationStepModels: Hashable, Equatable, Sendable {
        let dateOfOccurencePlusLocationModel: FlowClaimDateOfOccurrencePlusLocationStepModel?
        var dateOfOccurrenceModel: FlowClaimDateOfOccurenceStepModel?
        var locationModel: FlowClaimLocationStepModel?
    }

    public struct SummaryStepModels: Hashable, Sendable {
        let summaryStep: FlowClaimSummaryStepModel?
        let singleItemStepModel: FlowClaimSingleItemStepModel?
        let dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel
        let locationModel: FlowClaimLocationStepModel
        let audioRecordingModel: FlowClaimAudioRecordingStepModel?
        let fileUploadModel: FlowClaimFileUploadStepModel?
    }

    case setDateOfOccurence(model: FlowClaimDateOfOccurenceStepModel)
    case setDateOfOccurrencePlusLocation(model: DateOfOccurrencePlusLocationStepModels)
    case setPhoneNumber(model: FlowClaimPhoneNumberStepModel)
    case setLocation(model: FlowClaimLocationStepModel)
    case setSingleItem(model: FlowClaimSingleItemStepModel)
    case setSummaryStep(model: SummaryStepModels)
    case setSingleItemCheckoutStep(model: FlowClaimSingleItemCheckoutStepModel)
    case setSuccessStep(model: FlowClaimSuccessStepModel)
    case setFailedStep(model: FlowClaimFailedStepModel)
    case setAudioStep(model: FlowClaimAudioRecordingStepModel?)
    case setContractSelectStep(model: FlowClaimContractSelectStepModel)
    case setConfirmDeflectEmergencyStepModel(model: FlowClaimConfirmEmergencyStepModel)
    case setDeflectModel(model: FlowClaimDeflectStepModel)
    case setFileUploadStep(model: FlowClaimFileUploadStepModel?)
    case openUpdateAppScreen
}
