class InsuranceEvidenceClientDemo: InsuranceEvidenceClient {
    func getInitialData() async throws -> InsuranceEvidenceInitialData {
        return .init(email: "demo@hedvig.com")
    }

    func canCreateInsuranceEvidence() async throws -> Bool {
        return false
    }
    func createInsuranceEvidence(input: InsuranceEvidenceInput) async throws -> InsuranceEvidence {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return InsuranceEvidence(
            url: ""
        )

    }
}
