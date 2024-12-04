@preconcurrency import XCTest
import hCore

@testable import Addons

@MainActor
final class AddonsServiceTests: XCTestCase {
    weak var sut: MockAddonsService?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: AddonsClient.self)
        XCTAssertNil(sut)
    }

    func testFetchAddonDataSuccess() async throws {
        let selectedSubOption = AddonSubOptionModel(
            id: "subOptionId",
            title: "sub option title",
            subtitle: "sub option subTitle",
            price: .init(amount: "79", currency: "SEK")
        )

        let addonModel: AddonOffer = .init(
            id: "addonId",
            title: "title",
            subTitle: "subTitle",
            tag: "tag",
            informationText: "information text",
            options: [
                .init(
                    id: "optionId",
                    title: "option title",
                    subtitle: "option subTitle",
                    price: .init(amount: "49", currency: "SEK"),
                    subOptions: [
                        selectedSubOption
                    ]
                )
            ]
        )

        let mockService = MockData.createMockAddonsService(fetchAddon: {
            addonModel
        })

        self.sut = mockService

        let respondedAddonData = try await mockService.getAddon()

        assert(respondedAddonData == addonModel)
    }

    func testFetchContractDataSuccess() async throws {
        let contractId = "contractId"

        let contractModel = AddonContract(
            contractId: contractId,
            contractName: "contract name",
            displayItems: [
                .init(title: "display item 1", value: "1"),
                .init(title: "display item 2", value: "2"),
                .init(title: "display item 3", value: "3"),
            ],
            documents: [
                .init(displayName: "document1", url: "url", type: .generalTerms),
                .init(displayName: "document2", url: "url", type: .preSaleInfo),
                .init(displayName: "document3", url: "url", type: .termsAndConditions),
            ],
            insurableLimits: [
                .init(label: "label1", limit: "limit1", description: "description"),
                .init(label: "label2", limit: "limit2", description: "description"),
                .init(label: "label3", limit: "limit3", description: "description"),
            ],
            typeOfContract: nil,
            activationDate: Date(),
            currentPremium: .init(amount: "220", currency: "SEK")
        )

        let mockService = MockData.createMockAddonsService(fetchContract: { contractId in
            contractModel
        })

        self.sut = mockService

        let responedContractData = try await mockService.getContract(contractId: contractId)

        assert(responedContractData == contractModel)
    }
}
