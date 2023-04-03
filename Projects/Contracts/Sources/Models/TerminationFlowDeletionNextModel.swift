import Foundation
import hGraphQL

public struct TerminationFlowDeletionNextModel: FlowClaimStepModel {
    let id: String
    let disclaimer: String
    init(
        with data: OctopusGraphQL.FlowTerminationDeletionFragment
    ) {
        self.id = data.id
        self.disclaimer = data.disclaimer
    }
}
