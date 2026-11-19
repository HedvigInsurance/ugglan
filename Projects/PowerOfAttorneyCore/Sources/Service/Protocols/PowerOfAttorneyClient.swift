import Foundation
import hCore

@MainActor
public protocol PowerOfAttorneyClient: Sendable {
    func getPowerOfAttorneys() async throws -> [PowerOfAttorney]
    /// Starts a BankID signing of a power of attorney with the given level for the given user.
    func startSigning(
        for user: PowerOfAttorneyUser,
        level: PowerOfAttorneyLevel
    ) async throws -> PowerOfAttorneySigningSession
    /// Polls the signing status and emits it until it reaches `.success` or `.failed`.
    func observeSigningStatus(pollUrl: URL) -> AsyncThrowingStream<PowerOfAttorneySigningStatus, Error>
}
