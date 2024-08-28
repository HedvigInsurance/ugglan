import Foundation

public protocol FlowStepModel: Codable, Equatable, Hashable {}

public struct TerminationFlowDateNextStepModel: FlowStepModel {
    let id: String
    let maxDate: String
    let minDate: String
    var date: Date?

    init(
        id: String,
        maxDate: String,
        minDate: String,
        date: Date? = nil
    ) {
        self.id = id
        self.maxDate = maxDate
        self.minDate = minDate
        self.date = date
    }
}
