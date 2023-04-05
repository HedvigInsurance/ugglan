import Foundation
import hGraphQL

public struct TerminationFlowFailedNextModel: FlowClaimStepModel {
    let id: String
    init(
        with data: OctopusGraphQL.FlowTerminationFailedFragment
    ) {
        self.id = data.id
    }
}
