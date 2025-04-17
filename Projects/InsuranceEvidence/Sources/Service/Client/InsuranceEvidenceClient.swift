@MainActor
public protocol InsuranceEvidenceClient {
    func getInitialData() async throws -> InsuranceEvidenceInitialData
    func canCreateInsuranceEvidence() async throws -> Bool
    func createInsuranceEvidence(input: InsuranceEvidenceInput) async throws -> InsuranceEvidence
}
