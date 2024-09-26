public protocol ChangeTierClient {
    func getTier(contractId: String, tierSource: ChangeTierSource) async throws -> ChangeTierIntentModel
}
