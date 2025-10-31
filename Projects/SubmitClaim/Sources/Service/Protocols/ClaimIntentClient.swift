import Foundation
import hCore

@MainActor
public protocol ClaimIntentClient {
    func startClaimIntent() async throws -> ClaimIntent
    func claimIntentSubmitAudio(reference: String?, freeText: String?, stepId: String) async throws -> ClaimIntent
    func claimIntentSubmitForm(
        fields: [ClaimIntentStepContentForm.ClaimIntentStepContentFormField],
        stepId: String
    ) async throws -> ClaimIntent
    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntent
    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntent
    func getNextStep(claimIntentId: String) async throws -> ClaimIntentStep
}

@MainActor
class ClaimIntentService {
    @Inject var client: ClaimIntentClient

    func startClaimIntent() async throws -> ClaimIntent {
        let data = try await client.startClaimIntent()
        return data
    }

    func claimIntentSubmitAudio(reference: String?, freeText: String?, stepId: String) async throws -> ClaimIntent {
        let data = try await client.claimIntentSubmitAudio(reference: reference, freeText: freeText, stepId: stepId)
        return data
    }

    func claimIntentSubmitForm(
        fields: [ClaimIntentStepContentForm.ClaimIntentStepContentFormField],
        stepId: String
    ) async throws -> ClaimIntent {
        let data = try await client.claimIntentSubmitForm(fields: fields, stepId: stepId)
        return data
    }

    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntent {
        let data = try await client.claimIntentSubmitSummary(stepId: stepId)
        return data
    }

    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntent {
        let data = try await client.claimIntentSubmitTask(stepId: stepId)
        return data
    }

    func getNextStep(claimIntentId: String) async throws -> ClaimIntentStep {
        let data = try await client.getNextStep(claimIntentId: claimIntentId)
        return data
    }
}

public struct ClaimIntent: Sendable {
    let currentStep: ClaimIntentStep
    let id: String

    public init(currentStep: ClaimIntentStep, id: String) {
        self.currentStep = currentStep
        self.id = id
    }
}

public struct ClaimIntentStep: Sendable {
    public let content: ClaimIntentStepContent
    public let id: String
    public let text: String

    public init(
        content: ClaimIntentStepContent,
        id: String,
        text: String
    ) {
        self.content = content
        self.id = id
        self.text = text
    }
}

public enum ClaimIntentStepContent: Sendable {
    case form(model: ClaimIntentStepContentForm)
    case task(model: ClaimIntentStepContentTask)
    case audioRecording(model: ClaimIntentStepContentAudioRecording)
    case summary(model: ClaimIntentStepContentSummary)
    case text
}

public struct ClaimIntentStepContentForm: Sendable {
    let fields: [ClaimIntentStepContentFormField]

    public init(
        fields: [ClaimIntentStepContentFormField]
    ) {
        self.fields = fields
    }

    public struct ClaimIntentStepContentFormField: Sendable {
        let defaultValue: String?
        public let id: String
        let isRequired: Bool
        let maxValue: String?
        let minValue: String?
        let options: [ClaimIntentStepContentFormFieldOption]
        let suffix: String?
        let title: String
        let type: ClaimIntentStepContentFormFieldType

        public init(
            defaultValue: String?,
            id: String,
            isRequired: Bool,
            maxValue: String?,
            minValue: String?,
            options: [ClaimIntentStepContentFormFieldOption],
            suffix: String?,
            title: String,
            type: ClaimIntentStepContentFormFieldType
        ) {
            self.defaultValue = defaultValue
            self.id = id
            self.isRequired = isRequired
            self.maxValue = maxValue
            self.minValue = minValue
            self.options = options
            self.suffix = suffix
            self.title = title
            self.type = type
        }
    }

    public struct ClaimIntentStepContentFormFieldOption: Sendable {
        let title: String
        let value: String

        public init(title: String, value: String) {
            self.title = title
            self.value = value
        }
    }

    public enum ClaimIntentStepContentFormFieldType: Sendable {
        case text
        case date
        case number
        case singleSelect
        case binary
    }
}

public struct ClaimIntentStepContentTask: Sendable {
    let description: String
    let isCompleted: Bool

    public init(description: String, isCompleted: Bool) {
        self.description = description
        self.isCompleted = isCompleted
    }
}

public struct ClaimIntentStepContentAudioRecording: Sendable {
    let hint: String

    public init(hint: String) {
        self.hint = hint
    }
}

public struct ClaimIntentStepContentSummary: Sendable {
    let audioRecordings: [ClaimIntentStepContentSummaryAudioRecording]
    let fileUploads: [ClaimIntentStepContentSummaryFileUpload]
    let items: [ClaimIntentStepContentSummaryItem]

    public init(
        audioRecordings: [ClaimIntentStepContentSummaryAudioRecording],
        fileUploads: [ClaimIntentStepContentSummaryFileUpload],
        items: [ClaimIntentStepContentSummaryItem]
    ) {
        self.audioRecordings = audioRecordings
        self.fileUploads = fileUploads
        self.items = items
    }

    public struct ClaimIntentStepContentSummaryAudioRecording: Sendable {
        let url: URL

        public init(url: URL) {
            self.url = url
        }
    }

    public struct ClaimIntentStepContentSummaryFileUpload: Sendable {
        let url: URL

        public init(url: URL) {
            self.url = url
        }
    }

    public struct ClaimIntentStepContentSummaryItem: Sendable {
        let title: String
        let value: String

        public init(title: String, value: String) {
            self.title = title
            self.value = value
        }
    }
}

//public struct SubmitClaimStepResponse: Sendable {
//    let claimId: String
//    let context: String
//    let progress: Float?
//    let step: SubmitClaimStep
//    let nextStepId: String
//
//    public init(claimId: String, context: String, progress: Float?, step: SubmitClaimStep, nextStepId: String) {
//        self.claimId = claimId
//        self.context = context
//        self.progress = progress
//        self.step = step
//        self.nextStepId = nextStepId
//    }
//}

//public enum SubmitClaimStep: Equatable, Sendable {
//    public struct DateOfOccurrencePlusLocationStepModels: Hashable, Equatable, Sendable {
//        let dateOfOccurencePlusLocationModel: FlowClaimDateOfOccurrencePlusLocationStepModel?
//        public internal(set) var dateOfOccurrenceModel: FlowClaimDateOfOccurenceStepModel?
//        public internal(set) var locationModel: FlowClaimLocationStepModel?
//
//        public init(
//            dateOfOccurencePlusLocationModel: FlowClaimDateOfOccurrencePlusLocationStepModel?,
//            dateOfOccurrenceModel: FlowClaimDateOfOccurenceStepModel? = nil,
//            locationModel: FlowClaimLocationStepModel? = nil
//        ) {
//            self.dateOfOccurencePlusLocationModel = dateOfOccurencePlusLocationModel
//            self.dateOfOccurrenceModel = dateOfOccurrenceModel
//            self.locationModel = locationModel
//        }
//    }
//
//    public struct SummaryStepModels: Hashable, Sendable {
//        let summaryStep: FlowClaimSummaryStepModel?
//        let singleItemStepModel: FlowClaimSingleItemStepModel?
//        let dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel
//        let locationModel: FlowClaimLocationStepModel
//        let audioRecordingModel: FlowClaimAudioRecordingStepModel?
//        let fileUploadModel: FlowClaimFileUploadStepModel?
//
//        public init(
//            summaryStep: FlowClaimSummaryStepModel?,
//            singleItemStepModel: FlowClaimSingleItemStepModel?,
//            dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel,
//            locationModel: FlowClaimLocationStepModel,
//            audioRecordingModel: FlowClaimAudioRecordingStepModel?,
//            fileUploadModel: FlowClaimFileUploadStepModel?
//        ) {
//            self.summaryStep = summaryStep
//            self.singleItemStepModel = singleItemStepModel
//            self.dateOfOccurenceModel = dateOfOccurenceModel
//            self.locationModel = locationModel
//            self.audioRecordingModel = audioRecordingModel
//            self.fileUploadModel = fileUploadModel
//        }
//    }
//
//    case setDateOfOccurence(model: FlowClaimDateOfOccurenceStepModel)
//    case setDateOfOccurrencePlusLocation(model: DateOfOccurrencePlusLocationStepModels)
//    case setPhoneNumber(model: FlowClaimPhoneNumberStepModel)
//    case setLocation(model: FlowClaimLocationStepModel)
//    case setSingleItem(model: FlowClaimSingleItemStepModel)
//    case setSummaryStep(model: SummaryStepModels)
//    case setSingleItemCheckoutStep(model: FlowClaimSingleItemCheckoutStepModel)
//    case setSuccessStep(model: FlowClaimSuccessStepModel)
//    case setFailedStep(model: FlowClaimFailedStepModel)
//    case setAudioStep(model: FlowClaimAudioRecordingStepModel?)
//    case setContractSelectStep(model: FlowClaimContractSelectStepModel)
//    case setConfirmDeflectEmergencyStepModel(model: FlowClaimConfirmEmergencyStepModel)
//    case setDeflectModel(model: FlowClaimDeflectStepModel)
//    case setFileUploadStep(model: FlowClaimFileUploadStepModel?)
//    case openUpdateAppScreen
//}
