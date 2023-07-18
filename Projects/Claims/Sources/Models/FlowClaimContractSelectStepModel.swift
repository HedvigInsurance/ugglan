import Foundation
import hGraphQL

public struct FlowClaimContractSelectStepModel: FlowClaimStepModel {
    let availableContractOptions: [FlowClaimContractSelectOptionModel]

    init(
        with data: OctopusGraphQL.FlowClaimContractSelectStepFragment
    ) {
        self.availableContractOptions = data.options.map({ .init(with: $0) })
    }
}

public struct FlowClaimContractSelectOptionModel: Codable, Equatable, Hashable {
    let displayName: String
    let id: String

    init(
        with data: OctopusGraphQL.FlowClaimContractSelectStepFragment.Option
    ) {
        self.displayName = data.displayName
        self.id = data.id
    }
}
