import Foundation
import hCore
import hGraphQL

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

struct DeflectQuestion: FlowClaimStepModel {
    let question: String
    let answer: String
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

    init(
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

    init(
        with data: OctopusGraphQL.FlowClaimDeflectEmergencyStepFragment
    ) {
        self.id = (Self.setDeflectType(idIn: data.id))
        self.warningText = L10n.submitClaimEmergencyInfoLabel
        infoSectionText = L10n.submitClaimEmergencyInsuranceCoverLabel
        infoSectionTitle = L10n.submitClaimEmergencyInsuranceCoverTitle
        questions = [
            .init(question: L10n.submitClaimEmergencyFaq1Title, answer: L10n.submitClaimEmergencyFaq1Label),
            .init(question: L10n.submitClaimEmergencyFaq2Title, answer: L10n.submitClaimEmergencyFaq2Label),
            .init(question: L10n.submitClaimEmergencyFaq3Title, answer: L10n.submitClaimEmergencyFaq3Label),
            .init(question: L10n.submitClaimEmergencyFaq4Title, answer: L10n.submitClaimEmergencyFaq4Label),
            .init(question: L10n.submitClaimEmergencyFaq5Title, answer: L10n.submitClaimEmergencyFaq5Label),
            .init(question: L10n.submitClaimEmergencyFaq6Title, answer: L10n.submitClaimEmergencyFaq6Label),

        ]
        self.partners = data.partners.map({
            .init(
                with: $0.fragments.flowClaimDeflectPartnerFragment,
                title: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                description: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                info: L10n.submitClaimGlobalAssistanceFootnote,
                buttonText: L10n.submitClaimGlobalAssistanceUrlLabel,
                largerImageSize: true
            )
        })
        infoText = nil
        infoViewText = nil
        infoViewTitle = nil
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

            ],
            partners: partners
        )
    }

    init(
        with data: OctopusGraphQL.FlowClaimDeflectPestsStepFragment
    ) {
        self.id = (Self.setDeflectType(idIn: data.id))
        self.infoText = L10n.submitClaimPestsInfoLabel
        infoSectionText = L10n.submitClaimPestsHowItWorksLabel
        infoSectionTitle = L10n.submitClaimHowItWorksTitle
        infoViewTitle = L10n.submitClaimPestsTitle
        infoViewText = L10n.submitClaimPestsInfoLabel
        self.partners = data.partners.map({
            .init(
                with: $0.fragments.flowClaimDeflectPartnerFragment,
                title: nil,
                description: L10n.submitClaimPestsCustomerServiceLabel,
                info: nil,
                buttonText: L10n.submitClaimPestsCustomerServiceButton
            )
        })
        warningText = nil
        questions = []
    }

    init(
        with data: OctopusGraphQL.FlowClaimDeflectGlassDamageStepFragment
    ) {
        self.id = (Self.setDeflectType(idIn: data.id))
        self.infoText = L10n.submitClaimGlassDamageInfoLabel
        infoSectionText = L10n.submitClaimGlassDamageHowItWorksLabel
        infoSectionTitle = L10n.submitClaimHowItWorksTitle
        infoViewTitle = L10n.submitClaimGlassDamageTitle
        infoViewText = L10n.submitClaimGlassDamageInfoLabel
        self.partners = data.partners.map({
            .init(
                with: $0.fragments.flowClaimDeflectPartnerFragment,
                title: nil,
                description: L10n.submitClaimGlassDamageOnlineBookingLabel,
                info: nil,
                buttonText: L10n.submitClaimGlassDamageOnlineBookingButton
            )
        })
        warningText = nil
        questions = []
    }

    init(
        with data: OctopusGraphQL.FlowClaimDeflectTowingStepFragment
    ) {
        id = (Self.setDeflectType(idIn: data.id))
        infoText = L10n.submitClaimTowingInfoLabel
        infoSectionText = L10n.submitClaimTowingHowItWorksLabel
        infoSectionTitle = L10n.submitClaimHowItWorksTitle
        infoViewTitle = L10n.submitClaimTowingTitle
        infoViewText = L10n.submitClaimTowingInfoLabel
        questions = [
            .init(question: L10n.submitClaimTowingQ1, answer: L10n.submitClaimTowingA1),
            .init(question: L10n.submitClaimTowingQ2, answer: L10n.submitClaimTowingA2),
            .init(question: L10n.submitClaimTowingQ3, answer: L10n.submitClaimTowingA3),
        ]
        partners = data.partners.map({
            .init(
                with: $0.fragments.flowClaimDeflectPartnerFragment,
                title: nil,
                description: L10n.submitClaimTowingOnlineBookingLabel,
                info: nil,
                buttonText: L10n.submitClaimTowingOnlineBookingButton
            )
        })
        warningText = nil
    }

    init(
        with data: OctopusGraphQL.FlowClaimDeflectEirStepFragment
    ) {
        self.id = (Self.setDeflectType(idIn: data.id))
        partners = data.partners.map({
            .init(
                with: $0.fragments.flowClaimDeflectPartnerFragment,
                title: nil,
                description: nil,
                info: nil,
                buttonText: nil
            )
        })
        infoText = nil
        warningText = nil
        infoSectionText = nil
        infoSectionTitle = nil
        infoViewText = nil
        infoViewTitle = nil
        questions = []
    }

    init(
        with data: OctopusGraphQL.FlowClaimDeflectIDProtectionStepFragment
    ) {
        self.id = (Self.setDeflectType(idIn: data.id))
        self.partners = data.partners.map({
            .init(
                with: $0.deflectPartner.fragments.flowClaimDeflectPartnerFragment,
                title: $0.title,
                description: $0.description,
                info: $0.info,
                buttonText: $0.urlButtonTitle
            )
        })
        infoText = nil
        warningText = nil
        infoSectionText = data.description
        infoSectionTitle = data.title
        infoViewText = nil
        infoViewTitle = nil
        questions = []
    }

    private static func setDeflectType(idIn: String) -> FlowClaimDeflectStepType {
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

extension Partner {
    init(
        with data: OctopusGraphQL.FlowClaimDeflectPartnerFragment,
        title: String?,
        description: String?,
        info: String?,
        buttonText: String?,
        largerImageSize: Bool = false
    ) {
        self.init(
            id: data.id,
            imageUrl: data.imageUrl,
            url: data.url,
            phoneNumber: data.phoneNumber,
            title: title,
            description: description,
            info: info,
            buttonText: buttonText,
            largerImageSize: largerImageSize
        )
    }
}
