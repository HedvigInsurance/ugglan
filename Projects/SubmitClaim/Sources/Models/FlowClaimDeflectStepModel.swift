import Foundation
import hCore

public enum FlowClaimDeflectStepType: Decodable, Encodable, Sendable {
    case FlowClaimDeflectGlassDamageStep
    case FlowClaimDeflectPestsStep
    case FlowClaimDeflectEmergencyStep
    case FlowClaimDeflectTowingStep
    case FlowClaimDeflectEirStep
    case FlowClaimDeflectIDProtectionStep
    case Unknown

    public var title: String {
        switch self {
        case .FlowClaimDeflectGlassDamageStep:
            return L10n.submitClaimGlassDamageTitle
        case .FlowClaimDeflectPestsStep:
            return L10n.submitClaimPestsTitle
        case .FlowClaimDeflectEmergencyStep:
            return L10n.commonClaimEmergencyTitle
        case .FlowClaimDeflectTowingStep:
            return L10n.submitClaimTowingTitle
        case .FlowClaimDeflectEirStep:
            return L10n.submitClaimCarTitle
        case .FlowClaimDeflectIDProtectionStep:
            return L10n.submitClaimIdProtectionTitle
        case .Unknown:
            return ""
        }
    }
}

public struct DeflectQuestion: FlowClaimStepModel {
    let question: String
    let answer: String

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}

public struct FlowClaimDeflectStepModel: FlowClaimStepModel, Sendable {
    public let id: FlowClaimDeflectStepType
    let infoText: String?
    let warningText: String?
    let infoSectionText: String?
    let infoSectionTitle: String?
    let infoViewTitle: String?
    let infoViewText: String?
    let questions: [DeflectQuestion]
    let partners: [Partner]

    var isEmergencyStep: Bool {
        id == .FlowClaimDeflectEmergencyStep
    }

    public init(
        id: FlowClaimDeflectStepType,
        infoText: String?,
        warningText: String?,
        infoSectionText: String?,
        infoSectionTitle: String?,
        infoViewTitle: String?,
        infoViewText: String?,
        questions: [DeflectQuestion],
        partners: [Partner]
    ) {
        self.id = id
        self.infoText = infoText
        self.warningText = warningText
        self.infoSectionText = infoSectionText
        self.infoSectionTitle = infoSectionTitle
        self.infoViewTitle = infoViewTitle
        self.infoViewText = infoViewText
        self.questions = questions
        self.partners = partners
    }

    public static func emergency(with partners: [Partner]) -> FlowClaimDeflectStepModel {
        FlowClaimDeflectStepModel(
            id: .FlowClaimDeflectEmergencyStep,
            infoText: nil,
            warningText: L10n.submitClaimEmergencyInfoLabel,
            infoSectionText: L10n.submitClaimEmergencyInsuranceCoverLabel,
            infoSectionTitle: L10n.submitClaimEmergencyInsuranceCoverTitle,
            infoViewTitle: nil,
            infoViewText: nil,
            questions: [
                .init(question: L10n.submitClaimEmergencyFaq1Title, answer: L10n.submitClaimEmergencyFaq1Label),
                .init(question: L10n.submitClaimEmergencyFaq2Title, answer: L10n.submitClaimEmergencyFaq2Label),
                .init(question: L10n.submitClaimEmergencyFaq3Title, answer: L10n.submitClaimEmergencyFaq3Label),
                .init(question: L10n.submitClaimEmergencyFaq4Title, answer: L10n.submitClaimEmergencyFaq4Label),
                .init(question: L10n.submitClaimEmergencyFaq5Title, answer: L10n.submitClaimEmergencyFaq5Label),
                .init(question: L10n.submitClaimEmergencyFaq6Title, answer: L10n.submitClaimEmergencyFaq6Label),
                .init(question: L10n.submitClaimEmergencyFaq7Title, answer: L10n.submitClaimEmergencyFaq7Label),
                .init(question: L10n.submitClaimEmergencyFaq8Title, answer: L10n.submitClaimEmergencyFaq8Label),
            ],
            partners: partners
        )
    }

    public static func setDeflectType(idIn: String) -> FlowClaimDeflectStepType {
        switch idIn {
        case "FlowClaimDeflectGlassDamageStep":
            return .FlowClaimDeflectGlassDamageStep
        case "FlowClaimDeflectPestsStep":
            return .FlowClaimDeflectPestsStep
        case "FlowClaimDeflectEmergencyStep":
            return .FlowClaimDeflectEmergencyStep
        case "FlowClaimDeflectTowingStep":
            return .FlowClaimDeflectTowingStep
        case "FlowClaimDeflectEirStep":
            return .FlowClaimDeflectEirStep
        case "FlowClaimDeflectIDProtectionStep":
            return .FlowClaimDeflectIDProtectionStep
        default:
            return .Unknown
        }
    }
}
