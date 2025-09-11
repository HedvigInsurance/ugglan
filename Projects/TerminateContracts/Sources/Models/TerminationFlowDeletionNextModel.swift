import Foundation

public struct TerminationFlowDeletionNextModel: FlowStepModel {
    let id: String
    let extraCoverageItem: [ExtraCoverageItem]

    public init(
        id: String,
        extraCoverageItem: [ExtraCoverageItem]
    ) {
        self.id = id
        self.extraCoverageItem = extraCoverageItem
    }
}
