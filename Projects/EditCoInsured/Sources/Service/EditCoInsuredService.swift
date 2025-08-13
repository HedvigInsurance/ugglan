import Foundation
import hCore

@MainActor
public class EditCoInsuredService {
    @Inject var service: EditCoInsuredClient

    func sendMidtermChangeIntentCommit(commitId: String) async throws {
        log.info("EditCoInsuredService: sendMidtermChangeIntentCommit", error: nil, attributes: nil)
        return try await service.sendMidtermChangeIntentCommit(commitId: commitId)
    }

    func getPersonalInformation(SSN: String) async throws -> PersonalData? {
        log.info("EditCoInsuredService: getPersonalInformation", error: nil, attributes: nil)
        return try await service.getPersonalInformation(SSN: SSN)
    }

    func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> Intent {
        log.info("EditCoInsuredService: sendIntent", error: nil, attributes: nil)
        return try await service.sendIntent(contractId: contractId, coInsured: coInsured)
    }

    public func fetchContracts() async throws -> [Contract] {
        log.info("EditCoInsuredSharedService: fetchContracts", error: nil, attributes: nil)
        return try await service.fetchContracts()
    }
}
