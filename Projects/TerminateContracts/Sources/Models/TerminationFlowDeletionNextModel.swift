import Foundation
import hGraphQL

public struct TerminationFlowDeletionNextModel: FlowStepModel {
    let id: String
    let extraCoverageItem: [ExtraCoverageItem]

    init(
        id: String,
        extraCoverageItem: [ExtraCoverageItem]
    ) {
        self.id = id
        self.extraCoverageItem = extraCoverageItem
    }
}
