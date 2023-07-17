import Foundation
import hGraphQL

public struct FlowClaimContractSelectStepModel: FlowClaimStepModel {
    var selectedContractId: String
    var availableContractOptions: [FlowClaimContractSelectOptionModel]

    init(
        with data: OctopusGraphQL.FlowClaimContractSelectStepFragment
    ) {
        self.selectedContractId = data.id
        self.availableContractOptions = data.options.map({ option in
            FlowClaimContractSelectOptionModel(displayName: option.displayName, id: option.id)
        })
    }
}

public struct FlowClaimContractSelectOptionModel: Codable, Equatable, Hashable {
    let displayName: String
    let id: String

    init(
        displayName: String,
        id: String
    ) {
        self.displayName = displayName
        self.id = id
    }
}
