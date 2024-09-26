public protocol ChangeTierClient {
    func getTier(contractId: String) async throws -> ChangeTierIntentModel
}
