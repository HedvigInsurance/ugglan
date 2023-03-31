import Foundation
import hGraphQL

struct ClaimFlowLocationStepModel: ClaimFlowStepModel {
    let id: String
    let location: String?
    let options: [ClaimFlowLocationOptionModel]

    init(
        with data: OctopusGraphQL.FlowClaimLocationStepFragment
    ) {
        self.id = data.id
        self.location = data.location
        self.options = data.options.map({ .init(with: $0) })
    }
}

struct ClaimFlowLocationOptionModel: ClaimFlowStepModel {
    let displayName: String
    let value: String

    init(
        with data: OctopusGraphQL.FlowClaimLocationStepFragment.Option
    ) {
        self.displayName = data.displayName
        self.value = data.value
    }
}
