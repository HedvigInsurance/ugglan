public protocol SelectTierClient {
    func getTier(contractId: String) async throws -> ChangeTierIntentModel
}
