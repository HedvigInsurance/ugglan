final class ClaimIntentMemberClientDemo: ClaimIntentMemberClient {
    func fetchPhoneNumber() async throws -> String? {
        try await Task.sleep(seconds: 1)
        return nil
    }
    func updatePhoneNumber(phoneNumber: String) async throws {
        try await Task.sleep(seconds: 1)
    }
}
