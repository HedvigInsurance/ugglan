import AutomaticLog
import Logger
import hCore

@MainActor
class InsuranceEvidenceService {
    @Inject private var client: InsuranceEvidenceClient

    @Log
    func getInitialData() async throws -> InsuranceEvidenceInitialData {
        try await client.getInitialData()
    }

    @Log
    func canCreateInsuranceEvidence() async throws -> Bool {
        try await client.canCreateInsuranceEvidence()
    }

    @Log
    func createInsuranceEvidence(input: InsuranceEvidenceInput) async throws -> InsuranceEvidence {
        try await client.createInsuranceEvidence(input: input)
    }
}
