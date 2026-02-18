import Claims
import Foundation
import hCore
import hCoreUI

struct SingleItemModel: Equatable, Identifiable {
    static func == (lhs: SingleItemModel, rhs: SingleItemModel) -> Bool { lhs.id == rhs.id }
    let id: String
    let values: [SingleSelectValue]
    let multiselect: Bool
    let title: String

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
    let subtitle: String?
    let value: String
}

enum SubmitClaimChatMessageSender {
    case hedvig
    case member
}

public struct ClaimIntent: Sendable {
    let currentStep: ClaimIntentStep
    let id: String
    let isSkippable: Bool
    let isRegrettable: Bool
    let progress: Double
    let hint: String?

    public init(
        currentStep: ClaimIntentStep,
        id: String,
        isSkippable: Bool,
        isRegrettable: Bool,
        progress: Double,
        hint: String? = nil
    ) {
        self.currentStep = currentStep
        self.id = id
        self.isSkippable = isSkippable
        self.isRegrettable = isRegrettable
        self.progress = progress
        self.hint = hint
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
        let subtitle: String?
        let value: String

        public init(title: String, subtitle: String?, value: String) {
            self.title = title
            self.subtitle = subtitle
            self.value = value
        }
    }

    public enum ClaimIntentStepContentFormFieldType: Sendable {
        case text
        case date
        case number
        case phoneNumber
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
    let uploadURI: String
    let freeTextMinLength: Int
    let freeTextMaxLength: Int

    public init(uploadURI: String, freeTextMinLength: Int, freeTextMaxLength: Int) {
        self.uploadURI = uploadURI
        self.freeTextMinLength = freeTextMinLength
        self.freeTextMaxLength = freeTextMaxLength
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
    let style: ClaimIntentStepContentSelectStyle

    public enum ClaimIntentStepContentSelectStyle: Sendable {
        case pill
        case binary
    }

    public init(
        defaultSelectedId: String?,
        options: [ClaimIntentContentSelectOption],
        style: ClaimIntentStepContentSelectStyle
    ) {
        self.defaultSelectedId = defaultSelectedId
        self.options = options
        self.style = style
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
    let linkOnlyPartners: [LinkOnlyPartner]
    let buttonTitle: String

    public init(
        title: String?,
        content: ClaimIntentOutcomeDeflectionInfoBlock,
        partners: [Partner],
        infoText: String?,
        warningText: String?,
        questions: [DeflectQuestion],
        linkOnlyPartners: [LinkOnlyPartner],
        buttonTitle: String,
    ) {
        self.title = title
        self.content = content
        self.partners = partners.filter({ $0.imageUrl != nil })
        self.linkOnlyPartners = linkOnlyPartners
        self.infoText = infoText
        self.warningText = warningText
        self.questions = questions
        self.buttonTitle = buttonTitle
    }

    public struct ClaimIntentOutcomeDeflectionInfoBlock: Sendable, Hashable {
        let title: String
        let description: String

        public init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

    var hasSupportView: Bool {
        linkOnlyPartners.isEmpty
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
