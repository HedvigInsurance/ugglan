import Foundation
import hGraphQL

public struct FlowClaimPersonSelectStepModel: FlowClaimStepModel {
    let id: String
    let options: [FlowClaimPersonOptionModel]
    
    init(
        with data: OctopusGraphQL.FlowClaimPersonSelectStepFragment
    ) {
        self.id = data.id
        self.options = data.options.map({ FlowClaimPersonOptionModel.init(with: $0) })
    }
}

public struct FlowClaimPersonOptionModel: Codable, Equatable, Hashable {
    let fullName: String?
    let isHolder: Bool
    let isSelected: Bool
    let ssn: String?
    
    init(
        with data: OctopusGraphQL.FlowClaimPersonSelectStepFragment.Option
    ) {
        self.fullName = data.fullName
        self.isHolder = data.isHolder
        self.isSelected = data.isSelected
        self.ssn = data.ssn
    }
}
