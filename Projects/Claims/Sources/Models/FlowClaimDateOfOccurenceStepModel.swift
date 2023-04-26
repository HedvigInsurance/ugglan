import Foundation
import hGraphQL

public struct FlowClaimDateOfOccurenceStepModel: FlowClaimStepModel {
    let id: String
    var dateOfOccurence: String?
    let maxDate: String?

    init(
        with data: OctopusGraphQL.FlowClaimDateOfOccurrenceStepFragment
    ) {
        self.id = data.id
        self.dateOfOccurence = data.dateOfOccurrence
        self.maxDate = data.maxDate
    }

    func getMaxDate() -> Date {
        return maxDate?.localDateToDate ?? Date()
    }
}
