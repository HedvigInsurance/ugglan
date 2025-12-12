@MainActor
public protocol ClaimIntentMemberClient {
    func fetchPhoneNumber() async throws -> String?
    func updatePhoneNumber(phoneNumber: String) async throws
}
