import Foundation
import hGraphQL

public struct FlowClaimDateOfOccurrencePlusLocationStepModel: FlowClaimStepModel {
    let id: String
    init(
        with data: OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationStepFragment
    ) {
        self.id = data.id
    }
}
