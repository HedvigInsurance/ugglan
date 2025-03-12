import Foundation
import hGraphQL

public struct FlowClaimFailedStepModel: FlowClaimStepModel {
    let id: String

    init(
        id: String
    ) {
        self.id = id
    }
}
