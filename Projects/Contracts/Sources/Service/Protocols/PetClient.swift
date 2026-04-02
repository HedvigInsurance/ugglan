import Foundation

@MainActor
public protocol PetClient {
    func addMissing(petChipId: String, for contractId: String) async throws
}

public struct PetError: Error {
    public let message: String

    public init(message: String) {
        self.message = message
    }
}
