import Foundation

@MainActor
public protocol PowerOfAttorneyClient: Sendable {
    func getPowerOfAttorneys() async throws -> [PowerOfAttorney]
    func getCoInsured() async throws -> [PowerOfAttorneyUser]
    /// Looks up the person with the given personal number (name), for granting someone not in the co-insured list.
    func getUser(personalNumber: String) async throws -> PowerOfAttorneyUser
    /// Starts a BankID signing of a power of attorney with the given level for the given user.
    func startSigning(
        for user: PowerOfAttorneyUser,
        level: PowerOfAttorney.Level
    ) async throws -> PowerOfAttorneySigningSession
    /// Polls the signing status and emits it until it reaches `.success` or `.failed`.
    func observeSigningStatus(pollUrl: URL) -> AsyncThrowingStream<PowerOfAttorneySigningStatus, Error>
}
