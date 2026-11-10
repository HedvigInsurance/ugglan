import Apollo
import DatadogCore
import SwiftUI
import hCore
import hGraphQL

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
