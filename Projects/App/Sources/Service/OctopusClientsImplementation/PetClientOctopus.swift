import Contracts
import Foundation
import hCore
import hGraphQL

class PetChipIdClientOctopus: PetChipIdClient {
    @Inject private var octopus: hOctopus

    func addMissing(petChipId: String, for contractId: String) async throws {
        let mutation = OctopusGraphQL.MidtermChangePetIdMutation(contractId: contractId, petId: petChipId)

        let response = try await octopus.client.mutation(mutation: mutation)

        if let errorMessage = response?.midtermChangePetId.asUserError?.message {
            throw PetChipIdError(message: errorMessage)
        }
    }
}
