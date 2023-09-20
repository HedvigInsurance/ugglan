import Foundation
import hGraphQL

public struct FlowClaimDeflectEmergencyStepModel: FlowClaimStepModel {
    let id: String
    let partners: [Partner]
    
    init(
        with data: OctopusGraphQL.FlowClaimDeflectEmergencyStepFragment
    ) {
        self.id = data.id
        self.partners = data.partners.map({ partner in
                .init(
                    id: partner.id,
                    imageUrl: partner.imageUrl,
                    url: partner.url,
                    phoneNumber: partner.phoneNumber)
        })
    }
}

public struct Partner: Codable, Equatable, Hashable {
    let id: String
    let imageUrl: String
    let url: String?
    let phoneNumber: String?
    
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
