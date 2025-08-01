import Logger
import hCore

@MainActor
class InsuranceEvidenceService {
    @Inject private var client: InsuranceEvidenceClient
    func getInitialData() async throws -> InsuranceEvidenceInitialData {
        log.info("\(InsuranceEvidenceService.self) getInitialData", error: nil, attributes: [:])
        return try await client.getInitialData()
    }

    func canCreateInsuranceEvidence() async throws -> Bool {
        log.info("\(InsuranceEvidenceService.self) canCreateInsuranceEvidence", error: nil, attributes: [:])
        return try await client.canCreateInsuranceEvidence()
    }

    func createInsuranceEvidence(input: InsuranceEvidenceInput) async throws -> InsuranceEvidence {
        log.info("\(InsuranceEvidenceService.self) createInsuranceEvidence", error: nil, attributes: [:])
        return try await client.createInsuranceEvidence(input: input)
    }
}
