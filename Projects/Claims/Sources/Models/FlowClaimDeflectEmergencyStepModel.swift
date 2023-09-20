import Foundation
import hGraphQL

public struct FlowClaimDeflectEmergencyStepModel: FlowClaimStepModel {
    let id: String
    let partners: [Partner]
    
    init(
        with data: OctopusGraphQL.FlowClaimDeflectEmergencyStepFragment
    ) {
        self.id = data.id
        self.partners = data.partners.map({ .init(with: $0) })
    }
}

public struct Partner: Codable, Equatable, Hashable {
    let id: String
    let imageUrl: String
    let url: String?
    let phoneNumber: String?
    
    init(
        with data: OctopusGraphQL.FlowClaimDeflectEmergencyStepFragment.Partner
    ) {
        self.id = data.id
        self.imageUrl = data.imageUrl
        self.url = data.url
        self.phoneNumber = data.phoneNumber
    }
}
