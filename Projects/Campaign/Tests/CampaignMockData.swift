import hCore

@testable import Campaign

@MainActor
struct MockCampaignData {
    static func createMockCampaignService(
        fetchPaymentDiscountsData: @escaping FetchPaymentDiscountsData = {
            .init(
                discounts: [],
                referralsData: .init(
                    code: "code",
                    discountPerMember: .init(amount: "10", currency: "SEK"),
                    discount: .init(amount: "10", currency: "SEK"),
                    referrals: []
                )
            )
        }
    ) -> MockCampaignService {
        let service = MockCampaignService(
            fetchPaymentDiscountsData: fetchPaymentDiscountsData
        )
        Dependencies.shared.add(module: Module { () -> hCampaignClient in service })
        return service
    }
}

enum MockCampaignError: Error {
    case failure
}

typealias FetchPaymentDiscountsData = () async throws -> PaymentDiscountsData

class MockCampaignService: hCampaignClient {
    var events = [Event]()
    var fetchPaymentDiscountsData: FetchPaymentDiscountsData

    enum Event {
        case getPaymentDiscountsData
    }

    init(
        fetchPaymentDiscountsData: @escaping FetchPaymentDiscountsData
    ) {
        self.fetchPaymentDiscountsData = fetchPaymentDiscountsData
    }

    func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        events.append(.getPaymentDiscountsData)
        let data = try await fetchPaymentDiscountsData()
        return data
    }
}
