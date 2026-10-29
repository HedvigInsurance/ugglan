import Apollo
import AutomaticLog
import Combine
import DatadogCore
import SwiftUI
import hCore
import hGraphQL

@LogAll(.error)
@MainActor
class AnalyticsService {
    @Inject var client: AnalyticsClient
    @Inject var eventClient: EventTrackingClient
    fileprivate var setDeviceInfoTask: Task<(), Never>?
    func fetchAndSetUserId() async throws {
        let userId = try await client.fetchUserId()
        setWith(userId: userId)
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        setDeviceInfo(pushNotificationEnabled: settings.authorizationStatus == .authorized)
    }

    func setWith(userId: String) {
        client.setWith(userId: userId)
        eventClient.setUserId(userId)
    }

    func clearUserId() {
        eventClient.setUserId(nil)
    }

    deinit {
        setDeviceInfoTask?.cancel()
    }
}

// Lives in an extension so `@LogAll` doesn't attach `@Log` to it — the compiler crashes
// ("Failed to produce diagnostic") when this `Task { [weak self] in }` closure is inside a body macro.
extension AnalyticsService {
    fileprivate func setDeviceInfo(pushNotificationEnabled: Bool) {
        setDeviceInfoTask = Task { [weak self] in
            let memberLogDeviceModel = MemberLogDeviceModel(
                os: UIDevice.current.systemName,
                brand: "Apple",
                model: UIDevice.modelName,
                pushNotificationEnabled: pushNotificationEnabled
            )
            await self?.client.setDeviceInfo(model: memberLogDeviceModel)
        }
    }
}

struct AnalyticsClientOctopus: AnalyticsClient {
    @Inject private var octopus: hOctopus

    init() {}

    func fetchUserId() async throws -> String {
        let data = try await octopus.client.fetch(query: OctopusGraphQL.CurrentMemberIdQuery())
        return data.currentMember.id
    }

    func setWith(userId: String) {
        Task {
            let device_id = await ApolloClient.getDeviceIdentifier()
            let deviceModel = UIDevice.modelName
            Datadog.setUserInfo(
                id: userId,
                extraInfo: [
                    "device_id": device_id,
                    "member_id": userId,
                    "device_model": deviceModel,
                ]
            )
        }
    }

    func setDeviceInfo(model: MemberLogDeviceModel) async {
        let mutation = OctopusGraphQL.MemberLogDeviceMutation(input: model.asGraphQLInput)
        do {
            _ = try await octopus.client.mutation(mutation: mutation)
        } catch _ {
            //if fails retry in 1s or return if task is cancelledApolloClient.bundle = Bundle.main
            await delay(1)
            if Task.isCancelled {
                return
            }
            await setDeviceInfo(model: model)
        }
    }
}

extension MemberLogDeviceModel {
    var asGraphQLInput: OctopusGraphQL.MemberLogDeviceInput {
        OctopusGraphQL.MemberLogDeviceInput.init(
            os: self.os,
            brand: self.brand,
            model: self.model,
            pushNotificationEnabled: GraphQLNullable.some(self.pushNotificationEnabled)
        )
    }
}
