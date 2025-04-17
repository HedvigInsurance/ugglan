public class InsuranceEvidenceClientDemo: InsuranceEvidenceClient {

    public init() {}

    public func getInitialData() async throws -> InsuranceEvidenceInitialData {
        return .init(email: "demo@hedvig.com")
    }

    public func canCreateInsuranceEvidence() async throws -> Bool {
        return false
    }
    public func createInsuranceEvidence(input: InsuranceEvidenceInput) async throws -> InsuranceEvidence {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return InsuranceEvidence(
            url: ""
        )

    }
}
