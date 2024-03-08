public protocol ForeverService {
    func getMemberReferralInformation() async throws -> ForeverData
    func changeCode(code: String) async throws
}
