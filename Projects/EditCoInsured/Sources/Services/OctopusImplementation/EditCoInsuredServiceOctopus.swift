import Foundation
import hCore
import hGraphQL

public class EditCoInsuredServiceOctopus: EditCoInsuredService {
    @Inject var octopus: hOctopus
    public init() {}

    public func get(commitId: String) async throws {
        let mutation = OctopusGraphQL.MidtermChangeIntentCommitMutation(intentId: commitId)
        try await octopus.client.perform(mutation: mutation)
    }
}
