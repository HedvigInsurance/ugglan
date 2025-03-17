import Foundation
import hGraphQL

public protocol FlowClaimStepModel: Codable, Equatable, Hashable, Sendable {}

public struct FlowClaimSummaryStepModel: FlowClaimStepModel {
    let id: String
    var title: String
    let shouldShowDateOfOccurence: Bool
    let shouldShowLocation: Bool
    let shouldShowSingleItem: Bool

    init(
        id: String,
        title: String,
        shouldShowDateOfOccurence: Bool,
        shouldShowLocation: Bool,
        shouldShowSingleItem: Bool
    ) {
        self.id = id
        self.title = title
        self.shouldShowDateOfOccurence = shouldShowDateOfOccurence
        self.shouldShowLocation = shouldShowLocation
        self.shouldShowSingleItem = shouldShowSingleItem
    }
}
