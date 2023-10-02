import Foundation
import hGraphQL

enum FlowClaimDeflectStepType: Decodable, Encodable {
    case FlowClaimDeflectGlassDamageStep
    case FlowClaimDeflectPestsStep
    case FlowClaimDeflectEmergencyStep
    case Unknown
}

public struct FlowClaimDeflectStepModel: FlowClaimStepModel {
    let id: FlowClaimDeflectStepType
    let partners: [Partner]

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
