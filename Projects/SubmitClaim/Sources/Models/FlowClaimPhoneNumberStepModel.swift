import Foundation

public struct FlowClaimPhoneNumberStepModel: FlowClaimStepModel {
    let phoneNumber: String

    public init(
        phoneNumber: String
    ) {
        self.phoneNumber = phoneNumber
    }
}
