public class InsuranceEvidenceClientDemo: InsuranceEvidenceClient {
    public init() {}

    public func getInitialData() async throws -> InsuranceEvidenceInitialData {
        .init(email: "demo@hedvig.com")
    }

    public func canCreateInsuranceEvidence() async throws -> Bool {
        false
    }

    public func createInsuranceEvidence(input _: InsuranceEvidenceInput) async throws -> InsuranceEvidence {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return InsuranceEvidence(
            url: ""
        )
    }
}
