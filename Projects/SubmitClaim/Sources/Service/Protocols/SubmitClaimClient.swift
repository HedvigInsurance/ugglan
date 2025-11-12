import hCore

@MainActor
class SubmitClaimService {
    @Inject var client: SubmitClaimClient

    func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse {
        logInfo(
            "start claim for entrypointId: \(entrypointId ?? "--"), entrypointOptionId: \(entrypointOptionId ?? "--")"
        )
        let data = try await client.startClaim(entrypointId: entrypointId, entrypointOptionId: entrypointOptionId)
        data.logInfo()
        return data
    }

    func updateContact(
        phoneNumber: String,
        context: String,
        model: FlowClaimPhoneNumberStepModel
    ) async throws -> SubmitClaimStepResponse {
        logInfo("update contact for phoneNumber: \(phoneNumber)")
        let data = try await client.updateContact(phoneNumber: phoneNumber, context: context, model: model)
        data.logInfo()
        return data
    }

    func dateOfOccurrenceAndLocationRequest(
        context: String,
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels
    ) async throws -> SubmitClaimStepResponse {
        logInfo("dateOfOccurrenceAndLocationRequest \(model)")
        let data = try await client.dateOfOccurrenceAndLocationRequest(context: context, model: model)
        data.logInfo()
        return data
    }

    func submitAudioRecording(
        type: SubmitAudioRecordingType,
        context: String,
        currentClaimId: String,
        model: FlowClaimAudioRecordingStepModel
    ) async throws -> SubmitClaimStepResponse {
        logInfo("submitAudioRecording \(model)")
        let data = try await client.submitAudioRecording(
            type: type,
            context: context,
            currentClaimId: currentClaimId,
            model: model
        )
        data.logInfo()
        return data
    }

    func singleItemRequest(
        context: String,
        model: FlowClaimSingleItemStepModel
    ) async throws -> SubmitClaimStepResponse {
        logInfo("singleItemRequest \(model)")
        let data = try await client.singleItemRequest(context: context, model: model)
        data.logInfo()
        return data
    }

    func summaryRequest(
        context: String,
        model: SubmitClaimStep.SummaryStepModels
    ) async throws -> SubmitClaimStepResponse {
        logInfo("summaryRequest \(model)")
        let data = try await client.summaryRequest(context: context, model: model)
        data.logInfo()
        return data
    }

    func singleItemCheckoutRequest(
        context: String,
        model: FlowClaimSingleItemCheckoutStepModel
    ) async throws -> SubmitClaimStepResponse {
        logInfo("singleItemCheckoutRequest \(model)")
        let data = try await client.singleItemCheckoutRequest(context: context, model: model)
        data.logInfo()
        return data
    }

    func contractSelectRequest(
        contractId: String,
        context: String,
        model: FlowClaimContractSelectStepModel
    ) async throws -> SubmitClaimStepResponse {
        logInfo("contractSelectRequest \(contractId)")
        let data = try await client.contractSelectRequest(contractId: contractId, context: context, model: model)
        data.logInfo()
        return data
    }

    func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse {
        logInfo("emergencyConfirmRequest \(isEmergency)")
        let data = try await client.emergencyConfirmRequest(isEmergency: isEmergency, context: context)
        data.logInfo()
        return data
    }

    func submitFileUpload(
        ids: [String],
        context: String,
        model: FlowClaimFileUploadStepModel
    ) async throws -> SubmitClaimStepResponse {
        logInfo("submitFileUpload \(ids)")
        let data = try await client.submitFileUpload(ids: ids, context: context, model: model)
        data.logInfo()
        return data
    }
}

extension SubmitClaimService {
    func logInfo(_ message: String) {
        log.info("\(SubmitClaimService.self): \(message)", error: nil, attributes: [:])
    }
}

@MainActor
extension SubmitClaimStepResponse {
    func logInfo() {
        log.info(
            "\(SubmitClaimService.self): next step id is \(nextStepId)",
            error: nil,
            attributes: ["claimId": claimId]
        )
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

    public init(claimId: String, context: String, progress: Float?, step: SubmitClaimStep, nextStepId: String) {
        self.claimId = claimId
        self.context = context
        self.progress = progress
        self.step = step
        self.nextStepId = nextStepId
    }
}

public enum SubmitClaimStep: Equatable, Sendable {
    public struct DateOfOccurrencePlusLocationStepModels: Hashable, Equatable, Sendable {
        let dateOfOccurencePlusLocationModel: FlowClaimDateOfOccurrencePlusLocationStepModel?
        public internal(set) var dateOfOccurrenceModel: FlowClaimDateOfOccurenceStepModel?
        public internal(set) var locationModel: FlowClaimLocationStepModel?

        public init(
            dateOfOccurencePlusLocationModel: FlowClaimDateOfOccurrencePlusLocationStepModel?,
            dateOfOccurrenceModel: FlowClaimDateOfOccurenceStepModel? = nil,
            locationModel: FlowClaimLocationStepModel? = nil
        ) {
            self.dateOfOccurencePlusLocationModel = dateOfOccurencePlusLocationModel
            self.dateOfOccurrenceModel = dateOfOccurrenceModel
            self.locationModel = locationModel
        }
    }

    public struct SummaryStepModels: Hashable, Sendable {
        let summaryStep: FlowClaimSummaryStepModel?
        let singleItemStepModel: FlowClaimSingleItemStepModel?
        let dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel
        let locationModel: FlowClaimLocationStepModel
        let audioRecordingModel: FlowClaimAudioRecordingStepModel?
        let fileUploadModel: FlowClaimFileUploadStepModel?

        public init(
            summaryStep: FlowClaimSummaryStepModel?,
            singleItemStepModel: FlowClaimSingleItemStepModel?,
            dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel,
            locationModel: FlowClaimLocationStepModel,
            audioRecordingModel: FlowClaimAudioRecordingStepModel?,
            fileUploadModel: FlowClaimFileUploadStepModel?
        ) {
            self.summaryStep = summaryStep
            self.singleItemStepModel = singleItemStepModel
            self.dateOfOccurenceModel = dateOfOccurenceModel
            self.locationModel = locationModel
            self.audioRecordingModel = audioRecordingModel
            self.fileUploadModel = fileUploadModel
        }
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
