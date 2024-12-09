@preconcurrency import XCTest
import hCore

@testable import Payment
@testable import hCoreUI

@MainActor
final class CampaignViewModelTests: XCTestCase {
    weak var sut: MockCampaignService?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hCampaignClient.self)
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(sut)
    }

    func testAddCampaingCodeViewModelSuccess() async {
        let mockService = MockCampaignData.createMockCampaignService(
            addCampaign: {})

        MockPaymentData.createMockPaymentService()

        self.sut = mockService

        let model = AddCampaingCodeViewModel()
        await model.inputVm.save()

        assert(model.hideTitle == true)
        assert(model.codeAdded == true)
    }

    func testAddCampaingCodeViewModelFailure() async {
        let mockService = MockCampaignData.createMockCampaignService(
            addCampaign: { throw MockCampaignError.failure })

        MockPaymentData.createMockPaymentService()

        self.sut = mockService

        let model = AddCampaingCodeViewModel()
        await model.inputVm.save()

        assert(model.hideTitle == false)
        assert(model.codeAdded == false)
        assert(model.inputVm.error == MockCampaignError.failure.localizedDescription)
    }

    func testDeleteCampaignViewModelSuccess() async {
        let mockService = MockCampaignData.createMockCampaignService(
            removeCampaign: {})

        MockPaymentData.createMockPaymentService()

        self.sut = mockService

        let discount: Discount = .init(
            id: "id",
            code: "code",
            amount: .init(amount: "20", currency: "SEK"),
            title: "title",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: true
        )

        let model = DeleteCampaignViewModel(discount: discount)
        await model.removeCode()

        assert(model.codeRemoved == true)
        assert(model.isLoading == false)
        assert(model.discount == discount)
    }

    func testDeleteCampaignViewModelFailure() async {
        let mockService = MockCampaignData.createMockCampaignService(
            removeCampaign: { throw MockCampaignError.failure })

        MockPaymentData.createMockPaymentService()

        self.sut = mockService

        let discount: Discount = .init(
            id: "id",
            code: "code",
            amount: .init(amount: "20", currency: "SEK"),
            title: "title",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: true
        )

        let model = DeleteCampaignViewModel(discount: discount)
        await model.removeCode()

        assert(model.codeRemoved == false)
        assert(model.isLoading == false)
        assert(model.error == MockCampaignError.failure.localizedDescription)
    }
}
