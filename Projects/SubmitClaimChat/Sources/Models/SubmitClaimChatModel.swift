import Foundation

struct SingleItemModel: Equatable, Identifiable {
    static func == (lhs: SingleItemModel, rhs: SingleItemModel) -> Bool { lhs.id == rhs.id }
    let id: String
    let values: [SingleSelectValue]
}

struct SingleSelectValue: Hashable {
    let fieldId: String
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

    public init(
        currentStep: ClaimIntentStep,
        id: String,
        sourceMessages: [SourceMessage]
    ) {
        self.currentStep = currentStep
        self.id = id
        self.sourceMessages = sourceMessages
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
    case summary(model: ClaimIntentStepContentSummary)
    case outcome(model: ClaimIntentStepContentOutcome)
    case singleSelect(model: [ClaimIntentContentSelectOption])
    case text
    case unknown
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
    let uploadURI: String

    public init(
        hint: String,
        uploadURI: String
    ) {
        self.hint = hint
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

public struct ClaimIntentStepContentOutcome: Sendable, Equatable {
    let claimId: String

    public init(claimId: String) {
        self.claimId = claimId
    }
}
