import AutomaticLog
import Foundation
import hCore

@MainActor
class PowerOfAttorneyService {
    @Inject var client: PowerOfAttorneyClient

    @Log
    func getPowerOfAttorneys() async throws -> [PowerOfAttorney] {
        try await client.getPowerOfAttorneys()
    }

    @Log
    func getCoInsured() async throws -> [PowerOfAttorneyUser] {
        try await client.getCoInsured()
    }

    @Log(masked: ["personalNumber"])
    func getUser(personalNumber: String) async throws -> PowerOfAttorneyUser {
        try await client.getUser(personalNumber: personalNumber)
    }

    @Log
    func startSigning(
        for user: PowerOfAttorneyUser,
        level: PowerOfAttorney.Level
    ) async throws -> PowerOfAttorneySigningSession {
        try await client.startSigning(for: user, level: level)
    }

    // Not logged: returns a long-lived stream rather than a single result.
    func observeSigningStatus(pollUrl: URL) -> AsyncThrowingStream<PowerOfAttorneySigningStatus, Error> {
        client.observeSigningStatus(pollUrl: pollUrl)
    }
}
