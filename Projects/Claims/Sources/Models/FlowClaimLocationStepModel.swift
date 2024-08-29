import Foundation
import hGraphQL

public struct FlowClaimLocationStepModel: FlowClaimStepModel {
    let id: String
    var location: String?
    let options: [ClaimFlowLocationOptionModel]

    init(
        id: String,
        location: String? = nil,
        options: [ClaimFlowLocationOptionModel]
    ) {
        self.id = id
        self.location = location
        self.options = options
    }

    func getSelectedOption() -> ClaimFlowLocationOptionModel? {
        return options.first(where: { $0.value == location })
    }
}

public struct ClaimFlowLocationOptionModel: Codable, Equatable, Hashable {
    let displayName: String
    let value: String

    init(
        with data: OctopusGraphQL.FlowClaimLocationStepFragment.Option
    ) {
        self.displayName = data.displayName
        self.value = data.value
    }
}
