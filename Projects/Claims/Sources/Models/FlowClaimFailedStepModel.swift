import Foundation
import hGraphQL

public struct FlowClaimFailedStepModel: FlowClaimStepModel {
    let id: String
    init(
        with data: OctopusGraphQL.FlowClaimFailedStepFragment
    ) {
        self.id = data.id
    }
}
