@preconcurrency import XCTest
import hCore
import hCoreUI

@testable import Forever

@MainActor
final class ForeverTests: XCTestCase {
    weak var sut: MockForeverService?

    override func setUp() async throws {
        try await super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ForeverClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testFetchMemberReferralInformationSuccess() async {
        let memberReferralInformation: ForeverData = .init(
            grossAmount: .init(amount: "120", currency: "SEK"),
            netAmount: .init(amount: "110", currency: "SEK"),
            otherDiscounts: nil,
            discountCode: "discount code",
            monthlyDiscount: .init(amount: "10", currency: "SEK"),
            referrals: [],
            referredBy: nil,
            monthlyDiscountPerReferral: .init(amount: "10", currency: "SEK")
        )

        let mockService = MockData.createMockForeverService(
            fetchMemberReferralInformation: { memberReferralInformation }
        )
        sut = mockService

        let respondedInformation = try! await mockService.getMemberReferralInformation()
        assert(respondedInformation == memberReferralInformation)
    }

    func testCodeChangeSuccess() async {
        let code = "new code"

        let model = TextInputViewModel(
            masking: .init(type: .none),
            input: code,
            title: L10n.ReferralsEmpty.Code.headline
        )

        await model.save()
        assert(model.input == code)
    }
}
