import Claims
import Foundation
import hCore
import hCoreUI

struct SingleItemModel: Equatable, Identifiable {
    static func == (lhs: SingleItemModel, rhs: SingleItemModel) -> Bool { lhs.id == rhs.id }
    let id: String
    let values: [SingleSelectValue]
    let multiselect: Bool

    var attributes: [ItemPickerAttribute] {
        var result: [ItemPickerAttribute] = []

        if !multiselect {
            result.append(.singleSelect)
        }

        if values.count > 5 {
            result.append(.alwaysAttachToBottom)
        }

        return result
    }
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
    let isSkippable: Bool
    let isRegrettable: Bool

    public init(
        currentStep: ClaimIntentStep,
        id: String,
        isSkippable: Bool,
        isRegrettable: Bool
    ) {
        self.currentStep = currentStep
        self.id = id
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
    public let text: String?

    public init(
        content: ClaimIntentStepContent,
        id: String,
        text: String?
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
    case singleSelect(model: ClaimIntentStepContentSelect)
    case deflect(model: ClaimIntentOutcomeDeflection)
    case unknown
}

public enum ClaimIntentStepOutcome: Sendable, Hashable {
    case claim(model: ClaimIntentOutcomeClaim)
    case unknown
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

public struct ClaimIntentStepContentTask: Sendable, Equatable {
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

public struct ClaimIntentStepContentSelect: Sendable {
    let defaultSelectedId: String?
    let options: [ClaimIntentContentSelectOption]

    public init(defaultSelectedId: String?, options: [ClaimIntentContentSelectOption]) {
        self.defaultSelectedId = defaultSelectedId
        self.options = options
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
    let freeTexts: [String]

    public init(
        audioRecordings: [ClaimIntentStepContentSummaryAudioRecording],
        fileUploads: [ClaimIntentStepContentSummaryFileUpload],
        items: [ClaimIntentStepContentSummaryItem],
        freeTexts: [String]
    ) {
        self.audioRecordings = audioRecordings
        self.fileUploads = fileUploads
        self.items = items
        self.freeTexts = freeTexts
    }

    public struct ClaimIntentStepContentSummaryAudioRecording: Sendable {
        let url: URL

        public init(url: URL) {
            self.url = url
        }
    }

    public struct ClaimIntentStepContentSummaryFileUpload: Sendable {
        let url: URL
        let contentType: MimeType
        let fileName: String

        public init(url: URL, contentType: MimeType, fileName: String) {
            self.url = url
            self.contentType = contentType
            self.fileName = fileName
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

public struct ClaimIntentOutcomeDeflection: Sendable, Hashable {
    let title: String?
    let content: ClaimIntentOutcomeDeflectionInfoBlock
    let partners: [Partner]
    let infoText: String?
    let warningText: String?
    let questions: [DeflectQuestion]
    let linkOnlyPartners: [Partner]

    public init(
        title: String?,
        content: ClaimIntentOutcomeDeflectionInfoBlock,
        partners: [Partner],
        infoText: String?,
        warningText: String?,
        questions: [DeflectQuestion]
    ) {
        self.title = title
        self.content = content
        self.partners = partners.filter({ $0.imageUrl != nil })
        self.linkOnlyPartners = partners.filter({ $0.imageUrl == nil })
        self.infoText = infoText
        self.warningText = warningText
        self.questions = questions
    }

    public struct ClaimIntentOutcomeDeflectionInfoBlock: Sendable, Hashable {
        let title: String
        let description: String

        public init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }
}

public struct ClaimIntentOutcomeClaim: Sendable, Hashable {
    let claimId: String
    let claim: ClaimModel

    public init(claimId: String, claim: ClaimModel) {
        self.claimId = claimId
        self.claim = claim
    }
}
