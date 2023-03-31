import Foundation
import hGraphQL

struct ClaimFlowDateOfOccurenceStepModel: ClaimFlowStepModel {
    let id: String
    let dateOfOccurence: String?
    let maxDate: String?

    init(
        with data: OctopusGraphQL.FlowClaimDateOfOccurrenceStepFragment
    ) {
        self.id = data.id
        self.dateOfOccurence = data.dateOfOccurrence
        self.maxDate = data.maxDate
    }
}
