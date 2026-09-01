import AppStateContainer
import SubmitClaimChat
import TerminateContracts
import XCTest
import hCore

@testable import ChangeTier
@testable import Contracts
@testable import Home

@MainActor
final class QuickActionsViewModelTests: XCTestCase {
    // Leak detection per repo convention: every test assigns its view model here, so tearDown proves
    // performing an action left no retain cycle behind. Only the synchronous cases are exercised --
    // perform(.cancellation) spawns a Task that captures self strongly, so it would legitimately
    // outlive the test body.
    weak var sut: QuickActionsViewModel?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
        // perform(.upgradeCoverage) reads the global ContractStore singleton, so start
        // every test from a known-empty slate regardless of what ran before it.
        let contractStore: ContractStore = globalAppStateContainer.get()
        contractStore.activeContracts = []
        sut = nil
    }

    override func tearDown() async throws {
        let contractStore: ContractStore = globalAppStateContainer.get()
        contractStore.activeContracts = []
        // Let any pending release drain before checking the weak reference.
        try await Task.sleep(seconds: 0.0000001)

        XCTAssertNil(sut)
        try await super.tearDown()
    }

    func testPerformTravelInsurancePresentsTravelCertificate() {
        let vm = QuickActionsViewModel()
        sut = vm

        vm.perform(.travelInsurance)

        XCTAssertTrue(vm.isTravelCertificatePresented)
    }

    func testPerformChangeAddressPresentsChangeAddress() {
        let vm = QuickActionsViewModel()
        sut = vm

        vm.perform(.changeAddress)

        XCTAssertTrue(vm.isChangeAddressPresented)
    }

    func testPerformEditInsuranceStoresEditContractActions() {
        let vm = QuickActionsViewModel()
        sut = vm
        let wrapper = EditInsuranceActionsWrapper(quickActions: [.changeAddress, .editCoInsured])

        vm.perform(.editInsurance(actions: wrapper))

        XCTAssertEqual(vm.editContractActions, wrapper)
    }

    func testPerformFirstVetCapturesPartnersFromTheQuickAction() {
        let vm = QuickActionsViewModel()
        sut = vm
        let partners = [
            FirstVetPartner(id: "first", description: "description", url: nil, title: "title"),
            FirstVetPartner(id: "second", description: nil, url: "https://hedvig.com", title: nil),
        ]

        vm.perform(.firstVet(partners: partners))

        // The presented sheet renders these partners directly, so capturing them is the whole effect.
        XCTAssertEqual(vm.firstVetPartners?.partners, partners)
        XCTAssertEqual(vm.firstVetPartners?.id, "first,second")
    }

    func testPerformFirstVetWithNoPartnersStillPresents() {
        let vm = QuickActionsViewModel()
        sut = vm

        vm.perform(.firstVet(partners: []))

        XCTAssertEqual(vm.firstVetPartners?.partners, [])
    }

    func testPerformSickAbroadStoresSickAbroadData() {
        let vm = QuickActionsViewModel()
        sut = vm
        let deflection = SubmitClaimChat.Deflection(
            title: nil,
            content: .init(title: "", description: ""),
            partners: [],
            infoText: nil,
            warningText: nil,
            questions: [],
            linkOnlyPartners: [],
            buttonTitle: ""
        )

        vm.perform(.sickAbroad(deflection: deflection))

        XCTAssertEqual(vm.sickAbroadData, deflection)
    }

    func testPerformUpgradeCoveragePresentsChangeTierWithEligibleActiveContracts() {
        let contractStore: ContractStore = globalAppStateContainer.get()
        contractStore.activeContracts = [
            makeContract(
                id: "eligible",
                displayName: "Home Insurance",
                exposureDisplayName: "Apartment",
                supportsChangeTier: true
            ),
            makeContract(
                id: "ineligible",
                displayName: "Car Insurance",
                exposureDisplayName: "Car",
                supportsChangeTier: false
            ),
        ]
        let vm = QuickActionsViewModel()
        sut = vm

        vm.perform(.upgradeCoverage)

        let expectedContract = ChangeTierContract(
            contractId: "eligible",
            contractDisplayName: "Home Insurance",
            contractExposureName: "Apartment",
            typeOfContract: .seHouse
        )
        XCTAssertEqual(vm.isChangeTierPresented?.source, .changeTier)
        XCTAssertEqual(vm.isChangeTierPresented?.contracts, [expectedContract])
    }

    func testPerformUpgradeCoveragePresentsChangeTierWithNoContractsWhenStoreIsEmpty() {
        let vm = QuickActionsViewModel()
        sut = vm

        vm.perform(.upgradeCoverage)

        XCTAssertEqual(vm.isChangeTierPresented?.source, .changeTier)
        XCTAssertEqual(vm.isChangeTierPresented?.contracts, [])
    }

    func testPerformRemoveAddonsDoesNotMutateState() {
        let vm = QuickActionsViewModel()
        sut = vm

        vm.perform(.removeAddons)

        XCTAssertNil(vm.editContractActions)
        XCTAssertFalse(vm.isTravelCertificatePresented)
        XCTAssertFalse(vm.isChangeAddressPresented)
        XCTAssertNil(vm.firstVetPartners)
        XCTAssertNil(vm.sickAbroadData)
        XCTAssertNil(vm.isChangeTierPresented)
    }

    func testTerminationConfigsKeepsOnlyContractsSupportingTermination() {
        let vm = QuickActionsViewModel()
        sut = vm
        let contracts = [
            makeContract(
                id: "terminable-first",
                displayName: "Home Insurance",
                exposureDisplayName: "Apartment",
                supportsTermination: true
            ),
            makeContract(
                id: "not-terminable",
                displayName: "Car Insurance",
                exposureDisplayName: "Car",
                supportsTermination: false
            ),
            makeContract(
                id: "terminable-second",
                displayName: "Dog Insurance",
                exposureDisplayName: "Bamse",
                supportsTermination: true
            ),
        ]

        let configs = vm.terminationConfigs(from: contracts)

        XCTAssertEqual(configs.map(\.contractId), ["terminable-first", "terminable-second"])
        XCTAssertEqual(configs.map(\.contractDisplayName), ["Home Insurance", "Dog Insurance"])
        XCTAssertEqual(configs.map(\.contractExposureName), ["Apartment", "Bamse"])
    }
}

// Intentionally uncovered perform(_:) cases -- their observable effect lives outside the view model:
// - .connectPayments: delegates to ConnectPaymentViewModel.set(), whose state is private to that
//   view model and whose flow needs the payment service mocked end to end.
// - .editCoInsured / .editCoOwners: delegate to EditStakeholdersViewModel.start(stakeholderType:),
//   which reads existing stakeholders and drives its own navigation -- heavy service mocking for no
//   assertion the view model itself owns.
// - .cancellation's async Task: TerminateInsuranceViewModel.start(with:) hits the network. The part
//   the view model owns -- which contracts become TerminationConfirmConfigs -- is covered synchronously
//   by testTerminationConfigsKeepsOnlyContractsSupportingTermination.

// Minimal Contract fixture -- only the fields the view model actually reads
// (id, supportsChangeTier, supportsTermination, currentAgreement.productVariant.displayName,
// exposureDisplayName, typeOfContract) vary between call sites; the rest are fixed filler to satisfy
// the memberwise init.
private func makeContract(
    id: String,
    displayName: String,
    exposureDisplayName: String,
    supportsChangeTier: Bool = false,
    supportsTermination: Bool = false
) -> Contract {
    Contract(
        id: id,
        currentAgreement: .init(
            id: "agreement-\(id)",
            basePremium: .init(amount: "100", currency: "SEK"),
            itemCost: nil,
            displayItems: [],
            productVariant: .init(
                termsVersion: "1",
                typeOfContract: "SE_HOUSE",
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: displayName,
                displayNameTier: nil,
                tierDescription: nil
            ),
            addonVariant: []
        ),
        exposureDisplayName: exposureDisplayName,
        exposureDisplayNameShort: exposureDisplayName,
        masterInceptionDate: "2024-01-01",
        terminationDate: nil,
        supportsAddressChange: false,
        supportsCoInsured: false,
        supportsCoOwners: false,
        supportsTravelCertificate: false,
        supportsChangeTier: supportsChangeTier,
        supportsTermination: supportsTermination,
        upcomingChangedAgreement: nil,
        upcomingRenewal: nil,
        firstName: "Test",
        lastName: "Testson",
        ssn: nil,
        typeOfContract: .seHouse,
        coInsured: [],
        coOwners: [],
        missingPetChipId: false
    )
}
