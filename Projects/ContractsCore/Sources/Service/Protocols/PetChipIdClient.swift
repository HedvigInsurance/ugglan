import Foundation

@MainActor
public protocol PetChipIdClient {
    func addMissing(petChipId: String, for contractId: String) async throws
}

public struct PetChipIdError: Error {
    public let message: String

    public init(message: String) {
        self.message = message
    }
}
