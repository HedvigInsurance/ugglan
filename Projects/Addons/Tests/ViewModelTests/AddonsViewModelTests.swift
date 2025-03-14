@preconcurrency import XCTest
import hCore

@testable import Addons

@MainActor
final class AddonsViewModelTests: XCTestCase {
    weak var sut: MockAddonsService?
    weak var vm: ChangeAddonViewModel?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: AddonsClient.self)
        XCTAssertNil(sut)
        XCTAssertNil(vm)
    }

    func testFetchAddonSuccess() async throws {
        let selectedQuote = AddonQuote(
            displayName: "option title",
            quoteId: "quoteId1",
            addonId: "addonId1",
            addonSubtype: "addonSubtype1",
            displayItems: [],
            price: .init(amount: "49", currency: "SEK"),
            addonVariant: .init(
                displayName: "displayItem",
                documents: [],
                perils: [],
                product: "product",
                termsVersion: "termsVersion"
            )
        )

        let addonModel: AddonOffer = .init(
            titleDisplayName: "title",
            description: "description",
            activationDate: Date(),
            currentAddon: nil,
            quotes: [
                selectedQuote,
                .init(
                    displayName: "option title",
                    quoteId: "quoteId2",
                    addonId: "addonId2",
                    addonSubtype: "addonSubtype1",
                    displayItems: [],
                    price: .init(amount: "79", currency: "SEK"),
                    addonVariant: .init(
                        displayName: "displayItem",
                        documents: [],
                        perils: [],
                        product: "product",
                        termsVersion: "termsVersion"
                    )
                ),
            ]
        )

        let mockService = MockData.createMockAddonsService(fetchAddon: { contractId in
            addonModel
        })

        self.sut = mockService

        let model = ChangeAddonViewModel(contractId: "contractId", addonSource: .insurances)

        self.vm = model

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.addonOffer == addonModel)
        assert(model.addonOffer?.quotes == addonModel.quotes)
        assert(model.addonOffer?.quotes.count == addonModel.quotes.count)
        assert(model.fetchAddonsViewState == .success)
        assert(model.selectedQuote == selectedQuote)
    }

    func testFetchAddonFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddon: { contractId in
                throw AddonsError.somethingWentWrong
            }
        )

        self.sut = mockService

        let model = ChangeAddonViewModel(contractId: "contractId", addonSource: .insurances)

        self.vm = model

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.addonOffer?.quotes == nil)
        assert(model.addonOffer?.quotes.first == nil)
        assert(model.addonOffer?.quotes.count == nil)
        assert(model.selectedQuote == nil)

        if case .error(let errorMessage) = model.fetchAddonsViewState {
            assert(errorMessage == AddonsError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSubmitAddonSuccess() async throws {
        let mockService = MockData.createMockAddonsService(addonSubmit: { quoteId, addonId in

        })

        self.sut = mockService

        let model = ChangeAddonViewModel(contractId: "contractId", addonSource: .insurances)

        self.vm = model
        await model.submitAddons()

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.submittingAddonsViewState == .success)
    }

    func testSubmitAddonFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddon: { contractId in
                throw AddonsError.submitError
            },
            addonSubmit: { quoteId, addonId in
                throw AddonsError.submitError
            }
        )

        self.sut = mockService

        let model = ChangeAddonViewModel(contractId: "contractId", addonSource: .insurances)

        self.vm = model
        await model.submitAddons()

        try await Task.sleep(nanoseconds: 30_000_000)
        if case .error(let errorMessage) = model.submittingAddonsViewState {
            assert(errorMessage == AddonsError.submitError.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }
}
