import hCore
import hGraphQL

class NotificationClientOctopus: NotificationClient {
    @Inject var octopus: hOctopus

    func register(for token: String) async throws {
        let data = try await octopus.client
            .mutation(mutation: OctopusGraphQL.MemberDeviceRegisterMutation(token: token))
        if data?.memberDeviceRegister == true {
            log.info("Did register CustomerIO push token for user")
        } else {
            log.info("Failed to register CustomerIO push token for user")
        }
    }
}
