import XCTest
import hCore

@testable import ChangeTier
@testable import hCoreUI

final class ChangeTierViewModelTests: XCTestCase {
    weak var sut: MockChangeTierService?
    weak var vm: ChangeTierViewModel?

    let currentTier = Tier(
        id: "currentTier",
        name: "current tier",
        level: 1,
        deductibles: [],
        premium: .init(amount: "220", currency: "SEK"),
        displayItems: [],
        exposureName: nil,
        productVariant: nil,
        FAQs: []
    )
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
                displayName: "displayName",
                displayNameTier: nil,
                tierDescription: nil
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
                tierDescription: nil
            ),
            FAQs: []
        ),
    ]

    override func setUp() {
        super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ChangeTierClient.self)
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertNil(sut)
        XCTAssertNil(vm)
    }

    func testFetchTiersSuccess() async throws {
        let activationDate = "2024-12-12".localDateToDate ?? Date()
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            activationDate: activationDate,
            tiers: tiers,
            currentPremium: .init(amount: "449", currency: "SEK"),
            currentTier: currentTier,
            currentDeductible: nil,
            canEditTier: true
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))
        self.vm = model
        model.fetchTiers(nil)

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.tiers == tiers)
        assert(model.tiers.first == tiers.first)
        assert(model.tiers.count == tiers.count)
        assert(model.exposureName == "exposureName")
        assert(model.displayName == "displayName")
        assert(model.activationDate == activationDate)
        assert(model.canEditTier)
        assert(model.viewState == .success)
        assert(model.selectedTier == currentTier)
    }

    func testAddCampaingCodeViewModelFailure() async throws {
        let mockService = MockData.createMockChangeTier(
            fetchTier: { _ throws(ChangeTierError) in
                throw ChangeTierError.somethingWentWrong
            }
        )

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))
        self.vm = model
        model.fetchTiers(nil)
        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.canEditTier == false)
        assert(model.tiers.isEmpty)
        assert(model.exposureName == nil)
        assert(model.displayName == nil)
        assert(model.activationDate == nil)
        assert(model.selectedTier == nil)

        if case .error(let errorMessage) = model.viewState {
            assert(errorMessage == ChangeTierError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSetSelectedTierSuccess() async throws {
        let activationDate = "2024-12-12".localDateToDate ?? Date()
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            activationDate: activationDate,
            tiers: tiers,
            currentPremium: .init(amount: "449", currency: "SEK"),
            currentTier: currentTier,
            currentDeductible: nil,
            canEditTier: true
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))
        self.vm = model
        model.fetchTiers(nil)
        try await Task.sleep(nanoseconds: 30_000_000)
        await model.setTier(for: "max")
        assert(model.selectedTier?.name == "max")
        assert(model.selectedTier == tiers[1])
        assert(model.tiers == tiers)
        assert(model.tiers.first == tiers.first)
        assert(model.tiers.count == tiers.count)
        assert(model.exposureName == "exposureName")
        assert(model.displayName == "displayName")
        assert(model.activationDate == activationDate)
        assert(model.canEditTier)
        assert(model.viewState == .success)
    }

    func testSetSelectedTierFailure() async throws {
        let mockService = MockData.createMockChangeTier(
            fetchTier: { _ throws(ChangeTierError) in
                throw ChangeTierError.somethingWentWrong
            }
        )

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))
        self.vm = model
        model.fetchTiers(nil)
        try await Task.sleep(nanoseconds: 30_000_000)
        await model.setTier(for: "max")
        assert(model.selectedTier == nil)
        assert(model.canEditTier == false)
        assert(model.tiers.isEmpty)
        assert(model.exposureName == nil)
        assert(model.displayName == nil)
        assert(model.activationDate == nil)
        assert(model.selectedTier == nil)
        if case .error(let errorMessage) = model.viewState {
            assert(errorMessage == ChangeTierError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSetSelectedDeductibleSuccess() async throws {
        let activationDate = "2024-12-12".localDateToDate ?? Date()
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            activationDate: activationDate,
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
        self.vm = model
        try await Task.sleep(nanoseconds: 30_000_000)
        await model.setTier(for: "max")
        await model.setDeductible(for: model.selectedTier?.deductibles.first?.id ?? "")
        assert(model.selectedDeductible != nil)
        assert(model.selectedDeductible?.id == model.selectedTier?.deductibles.first?.id)
        assert(model.selectedTier == tiers[1])
        assert(model.selectedDeductible == tiers[1].deductibles[0])
        assert(model.tiers == tiers)
        assert(model.tiers.first == tiers.first)
        assert(model.tiers.count == tiers.count)
        assert(model.exposureName == "exposureName")
        assert(model.displayName == "displayName")
        assert(model.activationDate == activationDate)
        assert(model.canEditTier)
        assert(model.viewState == .success)
    }

    func testSetSelectedDeductibleFailure() async throws {
        let mockService = MockData.createMockChangeTier(
            fetchTier: { _ throws(ChangeTierError) in
                throw ChangeTierError.somethingWentWrong
            }
        )

        self.sut = mockService

        let model = ChangeTierViewModel(changeTierInput: .init(source: .changeTier, contractId: "contractId"))
        self.vm = model
        model.fetchTiers(nil)
        await model.setTier(for: "max")
        await model.setDeductible(for: model.selectedTier?.deductibles.first?.id ?? "")
        assert(model.selectedDeductible == nil)
        assert(model.selectedTier == nil)
        assert(model.canEditTier == false)
        assert(model.tiers.isEmpty)
        assert(model.exposureName == nil)
        assert(model.displayName == nil)
        assert(model.activationDate == nil)
        assert(model.selectedTier == nil)
        if case .error(let errorMessage) = model.viewState {
            assert(errorMessage == ChangeTierError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }
}
