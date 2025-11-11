import Foundation

public protocol FlowClaimStepModel: Codable, Equatable, Hashable, Sendable {}

public struct FlowClaimSummaryStepModel: FlowClaimStepModel {
    let title: String
    let subtitle: String?
    let selectedContractExposure: String?

    public init(
        title: String,
        subtitle: String?,
        selectedContractExposure: String?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.selectedContractExposure = selectedContractExposure
    }
}
