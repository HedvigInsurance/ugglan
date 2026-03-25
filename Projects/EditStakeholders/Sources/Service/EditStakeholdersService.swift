import Foundation
import hCore

@MainActor
public class EditStakeholdersService {
    @Inject var service: EditStakeholdersClient

    func commitMidtermChange(commitId: String) async throws {
        log.info("EditStakeholdersService: commitMidtermChange", error: nil, attributes: nil)
        return try await service.commitMidtermChange(commitId: commitId)
    }

    func fetchPersonalInformation(SSN: String) async throws -> PersonalData? {
        log.info("EditStakeholdersService: fetchPersonalInformation", error: nil, attributes: nil)
        return try await service.fetchPersonalInformation(SSN: SSN)
    }

    func createIntent(
        contractId: String,
        stakeholders: [Stakeholder],
        type: StakeholderType
    ) async throws -> Intent {
        log.info("EditStakeholdersService: createIntent", error: nil, attributes: nil)
        return try await service.createIntent(
            contractId: contractId,
            stakeholders: stakeholders,
            type: type
        )
    }

    public func fetchContracts() async throws -> [Contract] {
        log.info("EditStakeholdersService: fetchContracts", error: nil, attributes: nil)
        return try await service.fetchContracts()
    }
}
