import Foundation
import hGraphQL

public struct TerminationFlowSuccessNextModel: FlowStepModel {
    let terminationDate: String?
    init(
        with data: OctopusGraphQL.FlowTerminationSuccessFragment
    ) {
        self.terminationDate = data.terminationDate
    }

    init(
        terminationDate: String?
    ) {
        self.terminationDate = terminationDate
    }
}
