import Foundation
import hGraphQL

public struct TerminationFlowSuccessNextModel: FlowStepModel {
    let terminationDate: String?
    let surveyUrl: String?
    init(
        with data: OctopusGraphQL.FlowTerminationSuccessFragment
    ) {
        self.terminationDate = data.terminationDate
        self.surveyUrl = data.surveyUrl
    }

    init(
        terminationDate: String?,
        surveyUrl: String?
    ) {
        self.terminationDate = terminationDate
        self.surveyUrl = surveyUrl
    }
}
