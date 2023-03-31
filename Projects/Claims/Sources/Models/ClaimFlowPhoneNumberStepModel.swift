import Foundation
import hGraphQL

public struct ClaimFlowPhoneNumberStepModel: ClaimFlowStepModel {
    let id: String
    let phoneNumber: String

    init(
        with data: OctopusGraphQL.FlowClaimPhoneNumberStepFragment
    ) {
        self.id = data.id
        self.phoneNumber = data.phoneNumber

    }
}
