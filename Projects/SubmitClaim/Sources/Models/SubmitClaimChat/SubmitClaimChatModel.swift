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

enum SubmitClaimChatMesageSender {
    case hedvig
    case member
}
