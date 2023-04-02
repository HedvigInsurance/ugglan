import Foundation
import hGraphQL

public struct FlowClaimLocationStepModel: FlowClaimStepModel {
    let id: String
    var location: String?
    let options: [ClaimFlowLocationOptionModel]

    init(
        with data: OctopusGraphQL.FlowClaimLocationStepFragment
    ) {
        self.id = data.id
        self.location = data.location
        self.options = data.options.map({ .init(with: $0) })
    }

    func getSelectedOption() -> ClaimFlowLocationOptionModel? {
        return options.first(where: { $0.value == location })
    }
}

public struct ClaimFlowLocationOptionModel: Codable, Equatable {
    let displayName: String
    let value: String

    init(
        with data: OctopusGraphQL.FlowClaimLocationStepFragment.Option
    ) {
        self.displayName = data.displayName
        self.value = data.value
    }
}
