import Foundation
import hGraphQL

public struct FlowClaimContractSelectStepModel: FlowClaimStepModel {
    let availableContractOptions: [FlowClaimContractSelectOptionModel]
    var selectedContractId: String?

    init(
        availableContractOptions: [FlowClaimContractSelectOptionModel],
        selectedContractId: String? = nil
    ) {
        self.availableContractOptions = availableContractOptions
        self.selectedContractId = selectedContractId
    }
}

public struct FlowClaimContractSelectOptionModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let subTitle: String?
    let id: String
}
