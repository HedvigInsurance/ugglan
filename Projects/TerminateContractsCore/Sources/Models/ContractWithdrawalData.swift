import AutomaticLog
import Foundation

@Loggable
public struct ContractWithdrawalData: Codable, Equatable, Hashable, Sendable {
    public let statusText: String
    public let action: TerminationAction
    /// Where the withdrawal confirmation is sent.
    @Masked public let email: String

    public init(statusText: String, action: TerminationAction, email: String) {
        self.statusText = statusText
        self.action = action
        self.email = email
    }
}
