import EditCoInsuredShared
import Foundation
import hCore
import hGraphQL

public protocol EditCoInsuredClient {
    func sendMidtermChangeIntentCommit(commitId: String) async throws
    func getPersonalInformation(SSN: String) async throws -> PersonalData?
    func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> Intent
}
