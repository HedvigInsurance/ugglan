import Foundation
import hGraphQL

public protocol FlowClaimStepModel: Codable, Equatable, Hashable {}

public struct TerminationFlowDateNextStepModel: FlowClaimStepModel {
    let id: String
    let maxDate: String
    let minDate: String
    var date: Date?

    init(
        with data: OctopusGraphQL.FlowTerminationDateStepFragment
    ) {
        self.id = data.id
        self.minDate = data.minDate
        self.maxDate = data.maxDate
        self.date = nil
    }
}
