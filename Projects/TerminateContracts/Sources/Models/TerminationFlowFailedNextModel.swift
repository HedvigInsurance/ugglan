import Foundation
import hGraphQL

public struct TerminationFlowFailedNextModel: FlowStepModel {
    let id: String
    init(
        with data: OctopusGraphQL.FlowTerminationFailedFragment
    ) {
        self.id = data.id
    }
}
