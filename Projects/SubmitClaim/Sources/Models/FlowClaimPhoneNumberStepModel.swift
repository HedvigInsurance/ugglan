import Foundation
import hGraphQL

public struct FlowClaimPhoneNumberStepModel: FlowClaimStepModel {
    let id: String
    let phoneNumber: String

    init(
        id: String,
        phoneNumber: String
    ) {
        self.id = id
        self.phoneNumber = phoneNumber
    }
}
