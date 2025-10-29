@preconcurrency import XCTest
import hCore

@testable import ChangeTier
@testable import hCoreUI

@MainActor
final class ChangeTierViewModelTests: XCTestCase {
    weak var sut: MockChangeTierService?
    weak var vm: ChangeTierViewModel?

    let currentTier = Tier(
        id: "currentTier",
        name: "current tier",
        level: 1,
        quotes: [],
        exposureName: nil
    )
    let tiers: [Tier] = [
        .init(
            id: "id1",
            name: "standard",
            level: 1,
            quotes: [],
            exposureName: "exposureName"
        ),
        .init(
            id: "id2",
            name: "max",
            level: 2,
            quotes: [
                .init(
                    id: "id1",
                    quoteAmount: nil,
                    quotePercentage: nil,
                    subTitle: nil,
                    currentTotalCost: .init(gross: .sek(229), net: .sek(229)),
                    newTotalCost: .init(gross: .sek(229), net: .sek(229)),
                    displayItems: [],
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
                    addons: [],
                    costBreakdown: []
                )
            ],
            exposureName: "exposureName"
        ),
    ]

    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ChangeTierClient.self)
        try await Task.sleep(seconds: 0.02)
        XCTAssertNil(sut)
        XCTAssertNil(vm)
    }

    func testFetchTiersSuccess() async throws {
        let activationDate = "2024-12-12".localDateToDate ?? Date()
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            displayName: "display name",
            activationDate: activationDate,
            tiers: tiers,
            currentTier: currentTier,
            currentQuote: nil,
            selectedTier: nil,
            selectedQuote: nil,
            canEditTier: true,
            typeOfContract: .seHouse,
            relatedAddons: [:]
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        sut = mockService

        let model = ChangeTierViewModel(
            changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
        )
        vm = model

        try await Task.sleep(seconds: 0.03)
        var expectedTiers = tiers
        expectedTiers.insert(currentTier, at: 0)
        assert(model.tiers == expectedTiers)
        assert(model.tiers.first == expectedTiers.first)
        assert(model.tiers.count == expectedTiers.count)
        assert(model.exposureName == "exposureName")
        assert(model.displayName == "display name")
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

        sut = mockService

        let model = ChangeTierViewModel(
            changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
        )
        vm = model
        model.fetchTiers()
        try await Task.sleep(seconds: 0.03)
        assert(model.canEditTier == false)
        assert(model.tiers.isEmpty)
        assert(model.exposureName == nil)
        assert(model.displayName == nil)
        assert(model.activationDate == nil)
        assert(model.selectedTier == nil)

        if case let .error(errorMessage) = model.viewState {
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSetSelectedTierSuccess() async throws {
        let activationDate = "2024-12-12".localDateToDate ?? Date()
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            displayName: "display name",
            activationDate: activationDate,
            tiers: tiers,
            currentTier: currentTier,
            currentQuote: nil,
            selectedTier: nil,
            selectedQuote: nil,
            canEditTier: true,
            typeOfContract: .seHouse,
            relatedAddons: [:]
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        sut = mockService

        let model = ChangeTierViewModel(
            changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
        )
        vm = model
        model.fetchTiers()
        try await Task.sleep(seconds: 0.03)
        model.setTier(for: "max")
        assert(model.selectedTier?.name == "max")
        assert(model.selectedTier == tiers[1])
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

        sut = mockService

        let model = ChangeTierViewModel(
            changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
        )
        vm = model
        model.fetchTiers()
        try await Task.sleep(seconds: 0.03)
        model.setTier(for: "max")
        assert(model.selectedTier == nil)
        assert(model.canEditTier == false)
        assert(model.tiers.isEmpty)
        assert(model.exposureName == nil)
        assert(model.displayName == nil)
        assert(model.activationDate == nil)
        assert(model.selectedTier == nil)
        if case let .error(errorMessage) = model.viewState {
            assert(errorMessage == ChangeTierError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSetSelectedDeductibleSuccess() async throws {
        let activationDate = "2024-12-12".localDateToDate ?? Date()
        let changeTierIntentModel: ChangeTierIntentModel = .init(
            displayName: "display name",
            activationDate: activationDate,
            tiers: tiers,
            currentTier: nil,
            currentQuote: nil,
            selectedTier: nil,
            selectedQuote: nil,
            canEditTier: true,
            typeOfContract: .seHouse,
            relatedAddons: [:]
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        sut = mockService

        let model = ChangeTierViewModel(
            changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
        )
        vm = model
        try await Task.sleep(seconds: 0.03)
        model.setTier(for: "max")
        model.setDeductible(for: model.selectedTier?.quotes.first?.id ?? "")
        assert(model.selectedQuote != nil)
        assert(model.selectedQuote?.id == model.selectedTier?.quotes.first?.id)
        assert(model.selectedTier == tiers[1])
        assert(model.selectedQuote == tiers[1].quotes[0])
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

        sut = mockService

        let model = ChangeTierViewModel(
            changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
        )
        vm = model
        model.fetchTiers()
        model.setTier(for: "max")
        model.setDeductible(for: model.selectedTier?.quotes.first?.id ?? "")
        assert(model.selectedQuote == nil)
        assert(model.selectedTier == nil)
        assert(model.canEditTier == false)
        assert(model.tiers.isEmpty)
        assert(model.exposureName == nil)
        assert(model.displayName == nil)
        assert(model.activationDate == nil)
        assert(model.selectedTier == nil)
        try await Task.sleep(seconds: 0.0001)
        if case let .error(errorMessage) = model.viewState {
            assert(errorMessage == ChangeTierError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }
}
