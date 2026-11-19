import AutomaticLog
import ContractsCore
import EditStakeholdersCore
import Foundation
import hCore

@MainActor
public class PowerOfAttorneyService {
    @Inject var client: PowerOfAttorneyClient
    @Inject var contractsClient: FetchContractsClient
    @Inject var editStakeholdersClient: EditStakeholdersClient

    public init() {}

    @Log
    public func getPowerOfAttorneys() async throws -> [PowerOfAttorney] {
        try await client.getPowerOfAttorneys()
    }

    /// Co-insured on the member's active contracts that have a personal number (needed to grant a power of attorney).
    @Log
    public func getCoInsured() async throws -> [PowerOfAttorneyUser] {
        let contracts = try await contractsClient.getContracts()
        var seenPersonalNumbers = Set<String>()
        return contracts.activeContracts
            .flatMap(\.coInsured)
            .compactMap { coInsured -> PowerOfAttorneyUser? in
                guard
                    let firstName = coInsured.firstName,
                    let lastName = coInsured.lastName,
                    let personalNumber = coInsured.formattedSSN,
                    !personalNumber.isEmpty,
                    seenPersonalNumbers.insert(personalNumber).inserted
                else { return nil }
                return PowerOfAttorneyUser(
                    id: personalNumber,
                    firstName: firstName,
                    lastName: lastName,
                    ssn: personalNumber
                )
            }
    }

    /// Looks up the person with the given personal number, the same lookup as when adding a co-insured.
    @Log(masked: ["personalNumber"])
    public func getUser(personalNumber: String) async throws -> PowerOfAttorneyUser {
        guard let personalData = try await editStakeholdersClient.fetchPersonalInformation(SSN: personalNumber) else {
            throw PowerOfAttorneyError.error(message: L10n.General.errorBody)
        }
        return PowerOfAttorneyUser(
            id: personalNumber,
            firstName: personalData.firstName,
            lastName: personalData.lastName,
            ssn: personalNumber
        )
    }

    @Log
    public func startSigning(
        for user: PowerOfAttorneyUser,
        level: PowerOfAttorneyLevel
    ) async throws -> PowerOfAttorneySigningSession {
        try await client.startSigning(for: user, level: level)
    }

    // Not logged: returns a long-lived stream rather than a single result.
    public func observeSigningStatus(pollUrl: URL) -> AsyncThrowingStream<PowerOfAttorneySigningStatus, Error> {
        client.observeSigningStatus(pollUrl: pollUrl)
    }
}
