import Foundation
import hGraphQL

public struct FlowClaimDateOfOccurenceStepModel: FlowClaimStepModel {
    let id: String
    var dateOfOccurence: String?
    let maxDate: String?

    init(
        id: String,
        dateOfOccurence: String? = nil,
        maxDate: String?
    ) {
        self.id = id
        self.dateOfOccurence = dateOfOccurence
        self.maxDate = maxDate
    }
}
