import Foundation
import hCore

@testable import Forever

@MainActor
struct MockData {
    static func createMockForeverService(
        fetchMemberReferralInformation: @escaping FetchMemberReferralInformation = {
            .init(
                grossAmount: .init(amount: "120", currency: "SEK"),
                netAmount: .init(amount: "110", currency: "SEK"),
                otherDiscounts: nil,
                discountCode: "discount code",
                monthlyDiscount: .init(amount: "10", currency: "SEK"),
                referrals: [],
                referredBy: nil,
                monthlyDiscountPerReferral: .init(amount: "10", currency: "SEK")
            )
        },
        changeCode: @escaping ChangeCode = { _ in }
    ) -> MockForeverService {
        let service = MockForeverService(
            fetchMemberReferralInformation: fetchMemberReferralInformation,
            codeChange: changeCode
        )
        Dependencies.shared.add(module: Module { () -> ForeverClient in service })
        return service
    }
}

typealias FetchMemberReferralInformation = () async throws -> ForeverData
typealias ChangeCode = (String) async throws -> Void

class MockForeverService: ForeverClient {
    var events = [Event]()
    var fetchMemberReferralInformation: FetchMemberReferralInformation
    var codeChange: ChangeCode

    enum Event {
        case getMemberReferralInformation
        case changeCode
    }

    init(
        fetchMemberReferralInformation: @escaping FetchMemberReferralInformation,
        codeChange: @escaping ChangeCode
    ) {
        self.fetchMemberReferralInformation = fetchMemberReferralInformation
        self.codeChange = codeChange
    }

    func getMemberReferralInformation() async throws -> ForeverData {
        events.append(.getMemberReferralInformation)
        let data = try await fetchMemberReferralInformation()
        return data
    }

    func changeCode(code: String) async throws {
        events.append(.changeCode)
        try await codeChange(code)
    }
}
