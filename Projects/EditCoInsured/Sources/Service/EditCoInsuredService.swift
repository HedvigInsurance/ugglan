import AutomaticLog
import Foundation
import hCore

@MainActor
public class EditCoInsuredService {
    @Inject var service: EditCoInsuredClient

    @Log()
    func sendMidtermChangeIntentCommit(commitId: String) async throws {
        try await service.sendMidtermChangeIntentCommit(commitId: commitId)
    }

    @Log()
    func getPersonalInformation(SSN: String) async throws -> PersonalData? {
        try await service.getPersonalInformation(SSN: SSN)
    }

    @Log()
    func sendIntent(
        contractId: String,
        coInsured: [StakeHolder],
        stakeHolderType: StakeHolderType
    ) async throws -> Intent {
        try await service.sendIntent(
            contractId: contractId,
            coInsured: coInsured,
            stakeHolderType: stakeHolderType
        )
    }

    @Log()
    public func fetchContracts() async throws -> [Contract] {
        try await service.fetchContracts()
    }
}
