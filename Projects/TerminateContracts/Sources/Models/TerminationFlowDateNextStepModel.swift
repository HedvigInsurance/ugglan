import Foundation
import hGraphQL

public protocol FlowStepModel: Codable, Equatable, Hashable, Sendable {}

public struct TerminationFlowDateNextStepModel: FlowStepModel {
    let id: String
    let maxDate: String
    let minDate: String
    let extraCoverageItem: [ExtraCoverageItem]
    var date: Date?

    init(
        id: String,
        maxDate: String,
        minDate: String,
        date: Date? = nil,
        extraCoverageItem: [ExtraCoverageItem]
    ) {
        self.id = id
        self.maxDate = maxDate
        self.minDate = minDate
        self.date = date
        self.extraCoverageItem = extraCoverageItem
    }
}

public struct ExtraCoverageItem: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let displayValue: String?

    init(
        displayName: String,
        displayValue: String?
    ) {
        self.displayName = displayName
        self.displayValue = displayValue
    }
}
