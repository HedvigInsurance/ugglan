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

public struct SubmitClaimStepResponse {
    let claimId: String
    let context: String
    let progress: Float?
    let step: SubmitClaimStep
}

public enum SubmitClaimStep {
    public struct DateOfOccurrencePlusLocationStepModels: Hashable, Equatable {
        let dateOfOccurencePlusLocationModel: FlowClaimDateOfOccurrencePlusLocationStepModel?
        let dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel?
        let locationModel: FlowClaimLocationStepModel?
    }

    public struct SummaryStepModels: Hashable {
        let summaryStep: FlowClaimSummaryStepModel?
        let singleItemStepModel: FlowClamSingleItemStepModel?
        let dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel
        let locationModel: FlowClaimLocationStepModel
        let audioRecordingModel: FlowClaimAudioRecordingStepModel?
        let fileUploadModel: FlowClaimFileUploadStepModel?
    }

    case setDateOfOccurence(model: FlowClaimDateOfOccurenceStepModel)
    case setDateOfOccurrencePlusLocation(model: DateOfOccurrencePlusLocationStepModels)
    case setPhoneNumber(model: FlowClaimPhoneNumberStepModel)
    case setLocation(model: FlowClaimLocationStepModel)
    case setSingleItem(model: FlowClamSingleItemStepModel)
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
