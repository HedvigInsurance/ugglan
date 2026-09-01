import AutomaticLog
import hCore
import hGraphQL

@MainActor
public class NotificationService {
    @Inject var service: NotificationClient

    @Log(sensitive: ["token"])
    func register(for token: String) async throws {
        try await service.register(for: token)
    }
}

class NotificationClientOctopus: NotificationClient {
    @Inject var octopus: hOctopus

    func register(for token: String) async throws {
        _ = try await octopus.client
            .mutation(mutation: OctopusGraphQL.MemberDeviceRegisterMutation(token: token))
    }
}
