import Foundation
import hGraphQL

public struct FlowClaimSuccessStepModel: FlowClaimStepModel {
    let id: String

    init(
        id: String
    ) {
        self.id = id
    }
}
