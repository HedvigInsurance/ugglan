import hCore
import hGraphQL

@MainActor
public class NotificationService {
    @Inject var service: NotificationClient

    func register(for token: String) async throws {
        log.info("NotificationService: register for token", error: nil, attributes: nil)
        try await service.register(for: token)
    }
}

class NotificationClientOctopus: NotificationClient {
    @Inject var octopus: hOctopus

    func register(for token: String) async throws {
        let data = try await octopus.client
            .mutation(mutation: OctopusGraphQL.MemberDeviceRegisterMutation(token: token))
        if let data = data?.memberDeviceRegister {
            log.info("Did register CustomerIO push token for user")
        } else {
            log.info("Failed to register CustomerIO push token for user")
        }
    }
}
