import AutomaticLog
import Foundation
import hCore

@MainActor
public class PetChipIdService {
    @Inject private var client: PetChipIdClient

    @Log
    func addMissing(petChipId: String, for contractId: String) async throws {
        try await client.addMissing(petChipId: petChipId, for: contractId)
    }
}
