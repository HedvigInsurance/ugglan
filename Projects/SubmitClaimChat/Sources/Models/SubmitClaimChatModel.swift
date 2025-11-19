import Claims
import Foundation

struct SingleItemModel: Equatable, Identifiable {
    static func == (lhs: SingleItemModel, rhs: SingleItemModel) -> Bool { lhs.id == rhs.id }
    let id: String
    let values: [SingleSelectValue]
    let multiselect: Bool
}

struct SingleSelectValue: Hashable {
    let title: String
    let value: String
}

enum SubmitClaimChatMesageSender {
    case hedvig
    case member
}

public struct ClaimIntent: Sendable {
    let currentStep: ClaimIntentStep
    let id: String
    let sourceMessages: [SourceMessage]
    let outcome: ClaimIntentStepOutcome
    let isSkippable: Bool
    let isRegrettable: Bool

    public init(
        currentStep: ClaimIntentStep,
        id: String,
        sourceMessages: [SourceMessage],
        outcome: ClaimIntentStepOutcome,
        isSkippable: Bool,
        isRegrettable: Bool
    ) {
        self.currentStep = currentStep
        self.id = id
        self.sourceMessages = sourceMessages
        self.outcome = outcome
        self.isSkippable = isSkippable
        self.isRegrettable = isRegrettable
    }
}

public struct SourceMessage: Sendable {
    let id: String
    let text: String

    public init(id: String, text: String) {
        self.id = id
        self.text = text
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
    case fileUpload(model: ClaimIntentStepContentFileUpload)
    case summary(model: ClaimIntentStepContentSummary)
    case singleSelect(model: [ClaimIntentContentSelectOption])
    case text
    case unknown
}

public enum ClaimIntentStepOutcome: Sendable {
    case deflect(model: ClaimIntentOutcomeDeflection)
    case claim(model: ClaimIntentOutcomeClaim)
}

public struct ClaimIntentStepContentForm: Sendable {
    let fields: [ClaimIntentStepContentFormField]

    public init(fields: [ClaimIntentStepContentFormField]) {
        self.fields = fields
    }

    public struct ClaimIntentStepContentFormField: Sendable {
        let defaultValues: [String]
        public let id: String
        let isRequired: Bool
        let maxValue: String?
        let minValue: String?
        let options: [ClaimIntentStepContentFormFieldOption]
        let suffix: String?
        let title: String
        let type: ClaimIntentStepContentFormFieldType

        public init(
            defaultValues: [String],
            id: String,
            isRequired: Bool,
            maxValue: String?,
            minValue: String?,
            options: [ClaimIntentStepContentFormFieldOption],
            suffix: String?,
            title: String,
            type: ClaimIntentStepContentFormFieldType
        ) {
            self.defaultValues = defaultValues
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
        case multiSelect
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
    let uploadURI: String

    public init(hint: String, uploadURI: String) {
        self.hint = hint
        self.uploadURI = uploadURI
    }
}

public struct ClaimIntentStepContentFileUpload: Sendable {
    public let uploadURI: String

    public init(uploadURI: String) {
        self.uploadURI = uploadURI
    }
}

public struct ClaimIntentStepContentSummary: Sendable, Identifiable, Equatable {
    public static func == (lhs: ClaimIntentStepContentSummary, rhs: ClaimIntentStepContentSummary) -> Bool {
        lhs.id == rhs.id
    }

    public let id = UUID()
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

public struct ClaimIntentOutcomeDeflection: Sendable {
    let type: ClaimIntentOutcomeDeflectionType?
    let title: String?
    let description: String?
    let partners: [ClaimIntentOutcomeDeflectionPartner]

    public init(
        type: ClaimIntentOutcomeDeflectionType?,
        title: String?,
        description: String?,
        partners: [ClaimIntentOutcomeDeflectionPartner]
    ) {
        self.type = type
        self.title = title
        self.description = description
        self.partners = partners
    }

    public struct ClaimIntentOutcomeDeflectionPartner: Sendable {
        let id: String
        let imageUrl: String?
        let phoneNumber: String?
        let title: String?
        let description: String?
        let info: String?
        let url: String?
        let urlButtonTitle: String?

        public init(
            id: String,
            imageUrl: String?,
            phoneNumber: String?,
            title: String?,
            description: String?,
            info: String?,
            url: String?,
            urlButtonTitle: String?
        ) {
            self.id = id
            self.imageUrl = imageUrl
            self.phoneNumber = phoneNumber
            self.title = title
            self.description = description
            self.info = info
            self.url = url
            self.urlButtonTitle = urlButtonTitle
        }
    }

    public enum ClaimIntentOutcomeDeflectionType: Sendable {
        case emergency
        case glass
        case towing
        case eir
        case pests
        case idProtection
        case unknown
    }
}

public struct ClaimIntentOutcomeClaim: Sendable {
    let claimId: String
    let claim: ClaimModel

    public init(claimId: String, claim: ClaimModel) {
        self.claimId = claimId
        self.claim = claim
    }
}
