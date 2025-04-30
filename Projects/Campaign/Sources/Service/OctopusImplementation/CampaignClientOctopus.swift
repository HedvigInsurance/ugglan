import hCore
import hGraphQL

@MainActor
public class hCampaignService {
    @Inject var service: hCampaignClient

    public func remove(codeId: String) async throws {
        log.info("hCampaignService: remove", error: nil, attributes: nil)
        return try await service.remove(codeId: codeId)
    }

    public func add(code: String) async throws {
        log.info("hCampaignService: add", error: nil, attributes: nil)
        return try await service.add(code: code)
    }

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        log.info("hPaymentService: getPaymentDiscountsData", error: nil, attributes: nil)
        return try await service.getPaymentDiscountsData()
    }
}

public class hCampaignsClientOctopus: hCampaignClient {
    @Inject private var octopus: hOctopus
    public init() {}

    public func remove(codeId: String) async throws {
        let data = try await octopus.client.perform(
            mutation: OctopusGraphQL.MemberCampaignsUnredeemMutation(memberCampaignsUnredeemId: codeId)
        )
        if let errorMessage = data.memberCampaignsUnredeem.userError?.message {
            throw CampaignError.userError(message: errorMessage)
        }
    }

    public func add(code: String) async throws {
        let data = try await octopus.client.perform(mutation: OctopusGraphQL.RedeemCodeMutation(code: code))
        if let errorMessage = data.memberCampaignsRedeem.userError?.message {
            throw CampaignError.userError(message: errorMessage)
        }
    }

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        let query = OctopusGraphQL.DiscountsQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentDiscountsData.init(with: data, amountFromPaymentData: nil)
    }
}
