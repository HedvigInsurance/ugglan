import InsuranceEvidence
import hCore
import hGraphQL

class InsuranceEvidenceClientOctopus: InsuranceEvidenceClient {
    @Inject var octopus: hOctopus

    func getInitialData() async throws -> InsuranceEvidenceInitialData {
        let query = OctopusGraphQL.InsuranceEvidenceInitialDataQuery()
        let response = try await octopus.client.fetch(query: query)
        return .init(email: response.currentMember.email)
    }

    func canCreateInsuranceEvidence() async throws -> Bool {
        let query = OctopusGraphQL.InsuranceEvidenceCanCreateQuery()
        let response = try await octopus.client.fetch(query: query)
        return response.currentMember.memberActions?.isCreatingOfInsuranceEvidenceEnabled ?? false
    }

    func createInsuranceEvidence(input: InsuranceEvidenceInput) async throws -> InsuranceEvidence {
        let mutation = OctopusGraphQL.InsuranceEvidenceCreateMutation(input: .init(email: input.email))
        let response = try await octopus.client.mutation(mutation: mutation)
        guard let response = response?.insuranceEvidenceCreate.insuranceEvidenceInformation else {
            if let error = response?.insuranceEvidenceCreate.userError?.message {
                throw InsuranceEvidenceError.errorMessage(message: error)
            }
            throw InsuranceEvidenceError.errorMessage(message: L10n.General.defaultError)
        }
        return .init(url: response.signedUrl)
    }
}

enum InsuranceEvidenceError: Error {
    case errorMessage(message: String)
}
