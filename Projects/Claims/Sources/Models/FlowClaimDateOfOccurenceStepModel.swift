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

extension String {
    // converts a YYYY-MM-DD date-string to a Date
    var localDateToDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}
