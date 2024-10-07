import XCTest
import hCore

@testable import ChangeTier
@testable import hCoreUI

final class ChangeTierViewModelTests: XCTestCase {
    weak var sut: MockChangeTierService?

    let tiers: [Tier] = [
        .init(
            id: "id1",
            name: "standard",
            level: 1,
            deductibles: [],
            premium: .init(amount: "229", currency: ""),
            displayItems: [],
            exposureName: "exposureName",
            productVariant: .init(
                termsVersion: "",
                typeOfContract: "",
                partner: nil,
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: "",
                displayNameTier: nil,
                displayNameTierLong: nil
            ),
            FAQs: []
        ),
        .init(
            id: "id2",
            name: "max",
            level: 2,
            deductibles: [
                .init(
                    deductibleAmount: nil,
                    deductiblePercentage: nil,
                    subTitle: nil,
                    premium: .init(amount: "229", currency: "SEK")
                )
            ],
            premium: .init(amount: "229", currency: ""),
            displayItems: [],
            exposureName: "exposureName",
            productVariant: .init(
                termsVersion: "",
                typeOfContract: "",
                partner: nil,
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: "",
                displayNameTier: nil,
                displayNameTierLong: nil
            ),
            FAQs: []
        ),
    ]

    override func setUp() {
        super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ChangeTierClient.self)
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertNil(sut)
    }

    func testFetchTiersSuccess() async throws {
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            activationDate: Date(),
            tiers: tiers,
            currentPremium: .init(amount: "449", currency: "SEK"),
            currentTier: nil,
            currentDeductible: nil,
            canEditTier: true
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))

        model.fetchTiers(nil)

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.tiers == tiers)
        assert(model.tiers.first == tiers.first)
        assert(model.tiers.count == tiers.count)
    }

    func testAddCampaingCodeViewModelFailure() async throws {
        let mockService = MockData.createMockChangeTier(
            fetchTier: { _ throws(ChangeTierError) in
                throw ChangeTierError.somethingWentWrong
            }
        )

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))

        model.fetchTiers(nil)
        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.canEditTier == false)
        assert(model.tiers.isEmpty)
        if case .error(let errorMessage) = model.viewState {
            assert(errorMessage == ChangeTierError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSetSelectedTierSuccess() async throws {
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            activationDate: Date(),
            tiers: tiers,
            currentPremium: .init(amount: "449", currency: "SEK"),
            currentTier: nil,
            currentDeductible: nil,
            canEditTier: true
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))

        model.fetchTiers(nil)
        try await Task.sleep(nanoseconds: 30_000_000)
        await model.setTier(for: "max")
        assert(model.selectedTier?.name == "max")
    }

    func testSetSelectedTierFailure() async throws {
        let mockService = MockData.createMockChangeTier(
            fetchTier: { _ throws(ChangeTierError) in
                throw ChangeTierError.somethingWentWrong
            }
        )

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))

        model.fetchTiers(nil)
        try await Task.sleep(nanoseconds: 30_000_000)
        await model.setTier(for: "max")
        assert(model.selectedTier == nil)
        if case .error(let errorMessage) = model.viewState {
            assert(errorMessage == ChangeTierError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSetSelectedDeductibleSuccess() async throws {
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            activationDate: Date(),
            tiers: tiers,
            currentPremium: .init(amount: "449", currency: "SEK"),
            currentTier: nil,
            currentDeductible: nil,
            canEditTier: true
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))

        try await Task.sleep(nanoseconds: 30_000_000)
        await model.setTier(for: "max")
        await model.setDeductible(for: model.selectedTier?.deductibles.first?.id ?? "")
        assert(model.selectedDeductible != nil)
        assert(model.selectedDeductible?.id == model.selectedTier?.deductibles.first?.id)
    }

    func testSetSelectedDeductibleFailure() async throws {
        let mockService = MockData.createMockChangeTier(
            fetchTier: { _ throws(ChangeTierError) in
                throw ChangeTierError.somethingWentWrong
            }
        )

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))

        model.fetchTiers(nil)
        await model.setTier(for: "max")
        await model.setDeductible(for: model.selectedTier?.deductibles.first?.id ?? "")
        assert(model.selectedDeductible == nil)
        assert(model.selectedTier == nil)
        if case .error(let errorMessage) = model.viewState {
            assert(errorMessage == ChangeTierError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }
}
