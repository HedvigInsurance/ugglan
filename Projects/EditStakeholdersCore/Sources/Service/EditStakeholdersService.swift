import AutomaticLog
import Foundation
import hCore

@MainActor
public class EditStakeholdersService {
    @Inject var service: EditStakeholdersClient

    public init() {}

    @Log
    public func commitMidtermChange(commitId: String) async throws {
        try await service.commitMidtermChange(commitId: commitId)
    }

    @Log(masked: ["SSN"])
    public func fetchPersonalInformation(SSN: String) async throws -> PersonalData? {
        try await service.fetchPersonalInformation(SSN: SSN)
    }

    @Log
    public func createIntent(
        contractId: String,
        stakeholders: [Stakeholder],
        type: StakeholderType
    ) async throws -> Intent {
        try await service.createIntent(
            contractId: contractId,
            stakeholders: stakeholders,
            type: type
        )
    }

    @Log
    public func fetchContracts() async throws -> [Contract] {
        try await service.fetchContracts()
    }
}
