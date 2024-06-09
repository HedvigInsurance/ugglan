public protocol ForeverClient {
    func getMemberReferralInformation() async throws -> ForeverData
    func changeCode(code: String) async throws
}
