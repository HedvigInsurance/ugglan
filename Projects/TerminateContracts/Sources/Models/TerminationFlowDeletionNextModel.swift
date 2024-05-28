import Foundation
import hGraphQL

public struct TerminationFlowDeletionNextModel: FlowStepModel {
    let id: String

    init(
        with data: OctopusGraphQL.FlowTerminationDeletionFragment
    ) {
        self.id = data.id
    }

    public func returnDeltionInput() -> OctopusGraphQL.FlowTerminationDeletionInput {
        return OctopusGraphQL.FlowTerminationDeletionInput(confirmed: true)
    }
}
