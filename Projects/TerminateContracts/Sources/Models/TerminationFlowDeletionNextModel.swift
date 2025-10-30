import Foundation

public struct TerminationFlowDeletionNextModel: FlowStepModel {
    let extraCoverageItem: [ExtraCoverageItem]

    public init(
        extraCoverageItem: [ExtraCoverageItem]
    ) {
        self.extraCoverageItem = extraCoverageItem
    }
}
