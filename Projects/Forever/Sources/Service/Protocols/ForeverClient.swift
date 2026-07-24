@MainActor
public protocol ForeverClient: Sendable {
    func getMemberReferralInformation() async throws -> ForeverData
    func changeCode(code: String) async throws
}
