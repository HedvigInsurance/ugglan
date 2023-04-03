import Foundation
import hGraphQL

public struct TerminationFlowStartNextStepModel: FlowClaimStepModel {
    let contractId: String
    init(
        with data: OctopusGraphQL.FlowTerminationStartMutation
    ) {
        contractId = data.input.contractId
    }
}
