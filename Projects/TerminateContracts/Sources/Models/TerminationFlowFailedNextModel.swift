import Foundation
import hGraphQL

public struct TerminationFlowFailedNextModel: FlowStepModel {
    let id: String

    init(
        id: String
    ) {
        self.id = id
    }
}
