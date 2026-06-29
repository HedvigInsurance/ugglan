import AutomaticLog
import hCore

@MainActor
public class hCampaignService {
    @Inject var service: hCampaignClient

    @Log
    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        try await service.getPaymentDiscountsData()
    }
}
