import Foundation
import hGraphQL

public struct FlowClaimContractSelectStepModel: FlowClaimStepModel {
    let availableContractOptions: [FlowClaimContractSelectOptionModel]
    var selectedContractId: String?

    init(
        with data: OctopusGraphQL.FlowClaimContractSelectStepFragment
    ) {
        self.selectedContractId = data.options.first?.id
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
