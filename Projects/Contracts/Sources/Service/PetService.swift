import AutomaticLog
import Foundation
import hCore

@MainActor
public class PetService {
    @Inject var client: PetClient

    @Log
    func addMissing(petChipId: String, for contractId: String) async throws -> PetError? {
        try await client.addMissing(petChipId: petChipId, for: contractId)
    }
}
