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

        let model = ChangeAddonViewModel(contractId: "contractId")

        self.vm = model

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.addonOptions == addonModel.options)
        assert(model.addonOptions?.first == addonModel.options.first)
        assert(model.addonOptions?.count == addonModel.options.count)
        assert(model.informationText == addonModel.informationText)
        assert(model.fetchAddonsViewState == .success)
        assert(model.selectedSubOption == selectedSubOption)
    }

    func testFetchAddonFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddon: {
                throw AddonsError.emptyList
            },
            fetchContract: { contractId in
                throw AddonsError.emptyList
            }
        )

        self.sut = mockService

        let model = ChangeAddonViewModel(contractId: "contractId")

        self.vm = model

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.addonOptions == nil)
        assert(model.addonOptions?.first == nil)
        assert(model.addonOptions?.count == nil)
        assert(model.informationText == nil)
        assert(model.selectedSubOption == nil)

        if case .error(let errorMessage) = model.fetchAddonsViewState {
            assert(errorMessage == AddonsError.emptyList.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testFetchContractSuccess() async throws {
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

        let model = ChangeAddonViewModel(contractId: contractId)

        self.vm = model

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.contractInformation?.activationDate == contractModel.activationDate)
        assert(model.contractInformation?.contractId == contractModel.contractId)
        assert(model.contractInformation?.contractName == contractModel.contractName)
        assert(model.contractInformation?.currentPremium == contractModel.currentPremium)
        assert(model.contractInformation?.displayItems.count == contractModel.displayItems.count)
        assert(model.contractInformation?.displayItems.first?.id == contractModel.displayItems.first?.id)
        assert(model.contractInformation?.documents == contractModel.documents)
        assert(model.contractInformation?.insurableLimits == contractModel.insurableLimits)
        assert(model.contractInformation?.typeOfContract == contractModel.typeOfContract)
        assert(mockService.events.count == 2)
        assert(model.fetchAddonsViewState == .success)
    }

    func testFetchContractFailure() async throws {
        let contractId = "contractId"

        let mockService = MockData.createMockAddonsService(fetchContract: { contractId in
            throw AddonsError.somethingWentWrong
        })

        self.sut = mockService

        let model = ChangeAddonViewModel(contractId: contractId)

        self.vm = model

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.contractInformation?.activationDate == nil)
        assert(model.contractInformation?.contractId == nil)
        assert(model.contractInformation?.contractName == nil)
        assert(model.contractInformation?.currentPremium == nil)
        assert(model.contractInformation?.displayItems.count == nil)
        assert(model.contractInformation?.displayItems.first?.id == nil)
        assert(model.contractInformation?.documents == nil)
        assert(model.contractInformation?.insurableLimits == nil)
        assert(model.contractInformation?.typeOfContract == nil)

        if case .error(let errorMessage) = model.fetchAddonsViewState {
            assert(errorMessage == AddonsError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSubmitAddonSuccess() async throws {
        let mockService = MockData.createMockAddonsService(addonSubmit: {})

        self.sut = mockService

        let model = ChangeAddonViewModel(contractId: "contractId")

        self.vm = model
        await model.submitAddons()

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.submittingAddonsViewState == .success)
    }

    func testSubmitAddonFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddon: {
                throw AddonsError.submitError
            },
            fetchContract: { contractId in
                throw AddonsError.submitError
            },
            addonSubmit: {
                throw AddonsError.submitError
            }
        )

        self.sut = mockService

        let model = ChangeAddonViewModel(contractId: "contractId")

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
