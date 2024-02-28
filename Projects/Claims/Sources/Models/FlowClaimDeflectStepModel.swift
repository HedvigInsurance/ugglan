import Foundation
import hCore
import hGraphQL

enum FlowClaimDeflectStepType: Decodable, Encodable {
    case FlowClaimDeflectGlassDamageStep
    case FlowClaimDeflectPestsStep
    case FlowClaimDeflectEmergencyStep
    case Unknown
}

public struct FlowClaimDeflectConfig {
    let infoText: String
    let infoSectionText: String
    let infoSectionTitle: String
    let cardTitle: String
    let cardText: String
    let buttonText: String?
    let questions: [DeflectQuestion]
}

struct DeflectQuestion {
    let question: String
    let answer: String
}

public struct FlowClaimDeflectStepModel: FlowClaimStepModel {
    let id: FlowClaimDeflectStepType
    let partners: [Partner]
    var config: FlowClaimDeflectConfig? {
        if id == .FlowClaimDeflectGlassDamageStep {
            return FlowClaimDeflectConfig(
                infoText: L10n.submitClaimGlassDamageInfoLabel,
                infoSectionText: L10n.submitClaimGlassDamageHowItWorksLabel,
                infoSectionTitle: L10n.submitClaimHowItWorksTitle,
                cardTitle: L10n.submitClaimPartnerTitle,
                cardText: L10n.submitClaimGlassDamageOnlineBookingLabel,
                buttonText: L10n.submitClaimGlassDamageOnlineBookingButton,
                questions: [
                    .init(question: L10n.submitClaimWhatCostTitle, answer: L10n.submitClaimGlassDamageWhatCostLabel),
                    .init(question: L10n.submitClaimHowBookTitle, answer: L10n.submitClaimGlassDamageHowBookLabel),
                    .init(question: L10n.submitClaimWorkshopTitle, answer: L10n.submitClaimGlassDamageWorkshopLabel),
                ]
            )
        } else if id == .FlowClaimDeflectEmergencyStep {
            return FlowClaimDeflectConfig(
                infoText: L10n.submitClaimEmergencyInfoLabel,
                infoSectionText: L10n.submitClaimEmergencyInsuranceCoverLabel,
                infoSectionTitle: L10n.submitClaimEmergencyInsuranceCoverTitle,
                cardTitle: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                cardText: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                buttonText: nil,
                questions: [
                    .init(question: L10n.submitClaimEmergencyFaq1Title, answer: L10n.submitClaimEmergencyFaq1Label),
                    .init(question: L10n.submitClaimEmergencyFaq2Title, answer: L10n.submitClaimEmergencyFaq2Label),
                    .init(question: L10n.submitClaimEmergencyFaq3Title, answer: L10n.submitClaimEmergencyFaq3Label),
                    .init(question: L10n.submitClaimEmergencyFaq4Title, answer: L10n.submitClaimEmergencyFaq4Label),
                    .init(question: L10n.submitClaimEmergencyFaq5Title, answer: L10n.submitClaimEmergencyFaq5Label),
                    .init(question: L10n.submitClaimEmergencyFaq6Title, answer: L10n.submitClaimEmergencyFaq6Label),

                ]
            )
        } else if id == .FlowClaimDeflectPestsStep {
            return FlowClaimDeflectConfig(
                infoText: L10n.submitClaimPestsInfoLabel,
                infoSectionText: L10n.submitClaimPestsHowItWorksLabel,
                infoSectionTitle: L10n.submitClaimHowItWorksTitle,
                cardTitle: L10n.submitClaimPartnerTitle,
                cardText: L10n.submitClaimPestsCustomerServiceLabel,
                buttonText: L10n.submitClaimPestsCustomerServiceButton,
                questions: []
            )
        }
        return nil
    }

    init(
        with data: OctopusGraphQL.FlowClaimDeflectEmergencyStepFragment
    ) {
        self.id = (Self.setDeflectType(idIn: data.id))
        self.partners = data.partners.map({ .init(with: $0.fragments.flowClaimDeflectPartnerFragment) })
    }

    init(
        with data: OctopusGraphQL.FlowClaimDeflectPestsStepFragment
    ) {
        self.id = (Self.setDeflectType(idIn: data.id))
        self.partners = data.partners.map({ .init(with: $0.fragments.flowClaimDeflectPartnerFragment) })
    }

    init(
        with data: OctopusGraphQL.FlowClaimDeflectGlassDamageStepFragment
    ) {
        self.id = (Self.setDeflectType(idIn: data.id))
        self.partners = data.partners.map({ .init(with: $0.fragments.flowClaimDeflectPartnerFragment) })
    }

    init(
        id: FlowClaimDeflectStepType,
        partners: [Partner]? = []
    ) {
        self.id = id
        self.partners = partners ?? []
    }

    private static func setDeflectType(idIn: String) -> FlowClaimDeflectStepType {
        switch idIn {
        case "FlowClaimDeflectGlassDamageStep":
            return .FlowClaimDeflectGlassDamageStep
        case "FlowClaimDeflectPestsStep":
            return .FlowClaimDeflectPestsStep
        case "FlowClaimDeflectEmergencyStep":
            return .FlowClaimDeflectEmergencyStep
        default:
            return .Unknown
        }
    }
}

public struct Partner: Codable, Equatable, Hashable {
    let id: String
    let imageUrl: String
    let url: String?
    let phoneNumber: String?

    init(
        with data: OctopusGraphQL.FlowClaimDeflectPartnerFragment
    ) {
        self.id = data.id
        self.imageUrl = data.imageUrl
        self.url = data.url
        self.phoneNumber = data.phoneNumber
    }

    init(
        id: String,
        imageUrl: String,
        url: String?,
        phoneNumber: String?
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.url = url
        self.phoneNumber = phoneNumber
    }
}
