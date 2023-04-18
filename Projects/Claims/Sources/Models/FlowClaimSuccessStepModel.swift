import Foundation
import hGraphQL

public struct FlowClaimSuccessStepModel: FlowClaimStepModel {
    let id: String
    init(
        with data: OctopusGraphQL.FlowClaimSuccessStepFragment
    ) {
        self.id = data.id
    }
}
