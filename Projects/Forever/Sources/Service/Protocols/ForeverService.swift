public protocol ForeverService {
    func getMemberReferralInformation() async throws -> ForeverData
}
