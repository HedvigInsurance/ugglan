import Foundation
import hCore

@MainActor
public protocol PowerOfAttorneyClient: Sendable {
    func getPowerOfAttorneys() async throws -> [PowerOfAttorney]
    /// Powers of attorney other members have granted to the member, oldest first.
    func getReceivedPowerOfAttorneys() async throws -> [ReceivedPowerOfAttorney]
    /// Revokes a power of attorney the member has granted.
    func revokePowerOfAttorney(id: String) async throws
    /// Starts a BankID signing of a power of attorney with the given level for the given user.
    func startSigning(
        for user: PowerOfAttorneyUser,
        level: PowerOfAttorneyLevel
    ) async throws -> PowerOfAttorneySigningSession
    /// Polls the signing status and emits it until it reaches `.success` or `.failed`.
    func observeSigningStatus(pollUrl: URL) -> AsyncThrowingStream<PowerOfAttorneySigningStatus, Error>
}
