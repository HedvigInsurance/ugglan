import Apollo
import Combine
import DatadogCore
import SwiftUI
import hCore
import hGraphQL

@MainActor
class AnalyticsService {
    @Inject var client: AnalyticsClient
    private var setDeviceInfoTask: Task<(), Never>?
    func fetchAndSetUserId() async throws {
        log.info("AnalyticsService: fetchAndSetUserId", error: nil, attributes: nil)
        try await client.fetchAndSetUserId()
        setDeviceInfoTask = Task { [weak self] in
            let memberLogDeviceModel = MemberLogDeviceModel(
                os: UIDevice.current.systemName,
                brand: "Apple",
                model: UIDevice.modelName
            )
            log.info("AnalyticsService: setDeviceInfo \(memberLogDeviceModel.asString)", error: nil, attributes: nil)
            await self?.client.setDeviceInfo(model: memberLogDeviceModel)
        }
    }

    func setWith(userId: String) {
        log.info("AnalyticsService: setWith", error: nil, attributes: nil)
        client.setWith(userId: userId)
    }

    deinit {
        setDeviceInfoTask?.cancel()
    }
}

struct AnalyticsClientOctopus: AnalyticsClient {
    @Inject private var octopus: hOctopus

    init() {}

    func fetchAndSetUserId() async throws {
        let data = try await octopus.client.fetchQuery(query: OctopusGraphQL.CurrentMemberIdQuery())
        setWith(userId: data.currentMember.id)
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
            _ = try await octopus.client.performMutation(mutation: mutation)
        } catch _ {
            //if fails retry in 1s or return if task is cancelledApolloClient.bundle = Bundle.main
            try? await Task.sleep(nanoseconds: 1_000_000_000)
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
            model: self.model
        )
    }
}
