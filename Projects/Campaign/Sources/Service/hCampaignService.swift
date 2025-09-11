import hCore

@MainActor
public class hCampaignService {
    @Inject var service: hCampaignClient

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        log.info("hPaymentService: getPaymentDiscountsData", error: nil, attributes: nil)
        return try await service.getPaymentDiscountsData()
    }
}
