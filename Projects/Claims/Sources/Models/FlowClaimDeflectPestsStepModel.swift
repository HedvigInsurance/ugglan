import Foundation
import hGraphQL

public struct FlowClaimDeflectPestsStepModel: FlowClaimStepModel {
    let id: String
    let partners: [Partner]
    
    init(
        with data: OctopusGraphQL.FlowClaimDeflectPestsStepFragment
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
