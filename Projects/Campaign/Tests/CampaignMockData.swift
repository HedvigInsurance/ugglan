import hCore

@testable import Campaign

@MainActor
struct MockCampaignData {
    static func createMockCampaignService(
        removeCampaign: @escaping RemoveCampaign = {},
        addCampaign: @escaping AddCampaign = {},
        fetchPaymentDiscountsData: @escaping FetchPaymentDiscountsData = { discounts in
            .init(
                discounts: discounts,
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
            removeCampaign: removeCampaign,
            addCampaign: addCampaign,
            fetchPaymentDiscountsData: fetchPaymentDiscountsData
        )
        Dependencies.shared.add(module: Module { () -> hCampaignClient in service })
        return service
    }
}

enum MockCampaignError: Error {
    case failure
}

typealias RemoveCampaign = () async throws -> Void
typealias AddCampaign = () async throws -> Void
typealias FetchPaymentDiscountsData = ([Discount]) async throws -> PaymentDiscountsData

class MockCampaignService: hCampaignClient {
    var events = [Event]()

    var removeCampaign: RemoveCampaign
    var addCampaign: AddCampaign
    var fetchPaymentDiscountsData: FetchPaymentDiscountsData

    enum Event {
        case remove
        case add
        case getPaymentDiscountsData
    }

    init(
        removeCampaign: @escaping RemoveCampaign,
        addCampaign: @escaping AddCampaign,
        fetchPaymentDiscountsData: @escaping FetchPaymentDiscountsData
    ) {
        self.removeCampaign = removeCampaign
        self.addCampaign = addCampaign
        self.fetchPaymentDiscountsData = fetchPaymentDiscountsData
    }

    func remove(codeId: String) async throws {
        events.append(.remove)
        try await removeCampaign()
    }

    func add(code: String) async throws {
        events.append(.add)
        try await addCampaign()
    }

    func getPaymentDiscountsData(paymentDataDiscounts: [Discount]) async throws -> PaymentDiscountsData {
        events.append(.getPaymentDiscountsData)
        let data = try await fetchPaymentDiscountsData(paymentDataDiscounts)
        return data
    }
}
