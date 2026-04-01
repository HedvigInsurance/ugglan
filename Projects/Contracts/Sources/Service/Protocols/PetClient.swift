import Foundation

@MainActor
public protocol PetClient {
    func addMissing(petChipId: String, for contractId: String, ) async throws -> PetError?
}

public struct PetError {
    let message: String

    public init(message: String) {
        self.message = message
    }
}
