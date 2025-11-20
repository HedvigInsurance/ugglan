import Claims
import Foundation
import hCore
import hCoreUI

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
    let outcome: ClaimIntentStepOutcome?
    let isSkippable: Bool
    let isRegrettable: Bool

    public init(
        currentStep: ClaimIntentStep,
        id: String,
        sourceMessages: [SourceMessage],
        outcome: ClaimIntentStepOutcome?,
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

//public struct ClaimIntentStepOutcomeModel: Sendable, Hashable, TrackingViewNameProtocol {
//    public var nameForTracking: String {
//        return "outcome"
//    }
//
//    let model: ClaimIntentStepOutcome
//}

public enum ClaimIntentStepOutcome: Sendable, Hashable, TrackingViewNameProtocol {
    public var nameForTracking: String {
        ""
    }

    case deflect(model: ClaimIntentOutcomeDeflection)
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

public struct ClaimIntentOutcomeDeflection: Sendable, Hashable {
    let type: ClaimIntentOutcomeDeflectionType?
    let title: String?
    let description: String?
    let partners: [Partner]
    let infoText: String?
    let warningText: String?
    let infoSectionText: String?
    let infoSectionTitle: String?
    let questions: [DeflectQuestion]

    public init(
        type: ClaimIntentOutcomeDeflectionType?,
        title: String?,
        description: String?,
        partners: [Partner]
    ) {
        self.type = type
        self.title = title
        self.description = description
        self.partners = partners

        switch type {
        case .emergency:
            infoSectionText = L10n.submitClaimEmergencyInsuranceCoverLabel
            infoSectionTitle = L10n.submitClaimEmergencyInsuranceCoverTitle
            infoText = nil
            warningText = L10n.submitClaimEmergencyInfoLabel
            questions = [
                .init(question: L10n.submitClaimEmergencyFaq1Title, answer: L10n.submitClaimEmergencyFaq1Label),
                .init(question: L10n.submitClaimEmergencyFaq2Title, answer: L10n.submitClaimEmergencyFaq2Label),
                .init(question: L10n.submitClaimEmergencyFaq3Title, answer: L10n.submitClaimEmergencyFaq3Label),
                .init(question: L10n.submitClaimEmergencyFaq4Title, answer: L10n.submitClaimEmergencyFaq4Label),
                .init(question: L10n.submitClaimEmergencyFaq5Title, answer: L10n.submitClaimEmergencyFaq5Label),
                .init(question: L10n.submitClaimEmergencyFaq6Title, answer: L10n.submitClaimEmergencyFaq6Label),
                .init(question: L10n.submitClaimEmergencyFaq7Title, answer: L10n.submitClaimEmergencyFaq7Label),
                .init(question: L10n.submitClaimEmergencyFaq8Title, answer: L10n.submitClaimEmergencyFaq8Label),
            ]
        case .glass:
            infoText = L10n.submitClaimGlassDamageInfoLabel
            warningText = nil
            infoSectionText = L10n.submitClaimGlassDamageHowItWorksLabel
            infoSectionTitle = L10n.submitClaimHowItWorksTitle
            questions = []
        case .towing:
            infoText = L10n.submitClaimTowingInfoLabel
            warningText = nil
            infoSectionText = L10n.submitClaimTowingHowItWorksLabel
            infoSectionTitle = L10n.submitClaimHowItWorksTitle
            questions = [
                .init(question: L10n.submitClaimTowingQ1, answer: L10n.submitClaimTowingA1),
                .init(question: L10n.submitClaimTowingQ2, answer: L10n.submitClaimTowingA2),
                .init(question: L10n.submitClaimTowingQ3, answer: L10n.submitClaimTowingA3),
            ]
        case .eir:
            infoText = nil
            warningText = nil
            infoSectionText = nil
            infoSectionTitle = nil
            questions = []
        case .pests:
            infoText = L10n.submitClaimPestsInfoLabel
            warningText = nil
            infoSectionText = L10n.submitClaimPestsHowItWorksLabel
            infoSectionTitle = L10n.submitClaimHowItWorksTitle
            questions = []
        case .idProtection, .unknown, .none:
            infoText = nil
            warningText = nil
            infoSectionText = nil
            infoSectionTitle = nil
            questions = []
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

public struct ClaimIntentOutcomeClaim: Sendable, Hashable {
    let claimId: String
    let claim: ClaimModel

    public init(claimId: String, claim: ClaimModel) {
        self.claimId = claimId
        self.claim = claim
    }
}
