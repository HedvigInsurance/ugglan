import Foundation
import hGraphQL

public struct TerminationFlowDeletionNextModel: FlowStepModel {
    let id: String
    let disclaimer: String

    init(
        with data: OctopusGraphQL.FlowTerminationDeletionFragment
    ) {
        self.id = data.id
        self.disclaimer = data.disclaimer
    }

    public func returnDeltionInput() -> OctopusGraphQL.FlowTerminationDeletionInput {
        return OctopusGraphQL.FlowTerminationDeletionInput(confirmed: true)
    }
}
