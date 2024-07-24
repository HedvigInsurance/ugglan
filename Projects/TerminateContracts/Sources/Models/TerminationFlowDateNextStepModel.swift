import Foundation
import hGraphQL

public protocol FlowStepModel: Codable, Equatable, Hashable {}

public struct TerminationFlowDateNextStepModel: FlowStepModel {
    let id: String
    let maxDate: String
    let minDate: String
    var date: Date?

    init(id: String, maxDate: String, minDate: String, date: Date? = nil) {
        self.id = id
        self.maxDate = maxDate
        self.minDate = minDate
        self.date = date
    }

    init(
        with data: OctopusGraphQL.FlowTerminationDateStepFragment
    ) {
        self.id = data.id
        self.minDate = data.minDate
        self.maxDate = data.maxDate
        self.date = nil
    }
}
