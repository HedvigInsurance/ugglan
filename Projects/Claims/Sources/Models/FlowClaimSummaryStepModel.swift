import Foundation
import hGraphQL

public protocol FlowClaimStepModel: Codable, Equatable, Hashable {}

public struct FlowClaimSummaryStepModel: FlowClaimStepModel {
    let id: String
    var title: String
    let shouldShowDateOfOccurence: Bool
    let shouldShowLocation: Bool
    let shouldShowSingleItem: Bool
    init(
        with data: OctopusGraphQL.FlowClaimSummaryStepFragment
    ) {
        self.id = data.id
        self.title = data.title
        self.shouldShowDateOfOccurence = true
        self.shouldShowLocation = true
        self.shouldShowSingleItem = data.singleItemStep != nil
    }
}
