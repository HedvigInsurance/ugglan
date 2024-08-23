import Foundation
import hGraphQL

public struct TerminationFlowDeletionNextModel: FlowStepModel {
    let id: String

    init(
        id: String
    ) {
        self.id = id
    }
}
