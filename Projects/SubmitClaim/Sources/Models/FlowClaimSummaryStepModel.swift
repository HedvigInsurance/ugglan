import Foundation

public protocol FlowClaimStepModel: Codable, Equatable, Hashable, Sendable {}

public struct FlowClaimSummaryStepModel: FlowClaimStepModel {
    let id: String
    let title: String
    let subtitle: String?
    let shouldShowDateOfOccurence: Bool
    let shouldShowLocation: Bool
    let shouldShowSingleItem: Bool
    let selectedContractExposure: String?

    public init(
        id: String,
        title: String,
        subtitle: String?,
        shouldShowDateOfOccurence: Bool,
        shouldShowLocation: Bool,
        shouldShowSingleItem: Bool,
        selectedContractExposure: String?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.shouldShowDateOfOccurence = shouldShowDateOfOccurence
        self.shouldShowLocation = shouldShowLocation
        self.shouldShowSingleItem = shouldShowSingleItem
        self.selectedContractExposure = selectedContractExposure
    }
}
