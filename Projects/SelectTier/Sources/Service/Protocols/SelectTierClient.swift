public protocol SelectTierClient {
    func getTier() async throws -> TierModel
}
