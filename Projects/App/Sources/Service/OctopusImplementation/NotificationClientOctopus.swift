import hCore
import hGraphQL

public class NotificationService {
    @Inject var service: NotificationClient

    func register(for token: String) {
        log.info("EditCoInsuredService: sendMidtermChangeIntentCommit", error: nil, attributes: nil)
    }
}

class NotificationClientOctopus: NotificationClient {
    @Inject var octopus: hOctopus

    func register(for token: String) {
        octopus.client
            .perform(mutation: OctopusGraphQL.MemberDeviceRegisterMutation(token: token))
            .onValue({ data in
                if data.memberDeviceRegister == true {
                    log.info("Did register CustomerIO push token for user")
                } else {
                    log.info("Failed to register CustomerIO push token for user")
                }
            })
    }
}
