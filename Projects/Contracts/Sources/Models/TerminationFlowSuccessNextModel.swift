import Foundation
import hGraphQL

public struct TerminationFlowSuccessNextModel: FlowClaimStepModel {
    let terminationDate: String?
    let surveyUrl: String
    init(
        with data: OctopusGraphQL.FlowTerminationSuccessFragment
    ) {
        self.terminationDate = data.terminationDate
        self.surveyUrl = data.surveyUrl
    }
}
