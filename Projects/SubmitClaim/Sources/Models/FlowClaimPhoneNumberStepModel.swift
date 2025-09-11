import Foundation

public struct FlowClaimPhoneNumberStepModel: FlowClaimStepModel {
    let id: String
    let phoneNumber: String

    public init(
        id: String,
        phoneNumber: String
    ) {
        self.id = id
        self.phoneNumber = phoneNumber
    }
}
