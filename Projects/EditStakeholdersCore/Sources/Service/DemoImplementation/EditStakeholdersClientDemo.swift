import Foundation
import hCore

/// Demo mode only looks up personal numbers (e.g. when granting a power of attorney), the edit flow isn't supported.
public class EditStakeholdersClientDemo: EditStakeholdersClient {
    public init() {}

    public func commitMidtermChange(commitId _: String) async throws {
        throw EditStakeholdersError.otherError
    }

    public func fetchPersonalInformation(SSN _: String) async throws -> PersonalData? {
        try await Task.sleep(for: .seconds(1))
        return PersonalData(firstName: "Karin", lastName: "Berg")
    }

    public func createIntent(
        contractId _: String,
        stakeholders _: [Stakeholder],
        type _: StakeholderType
    ) async throws -> Intent {
        throw EditStakeholdersError.otherError
    }

    public func fetchContracts() async throws -> [Contract] {
        []
    }
}
