import AppStateContainer
import SubmitClaimChat
import TerminateContracts
import Testing
import hCore

@testable import ChangeTier
@testable import Contracts
@testable import Home

extension HomeDependencySuite {
    @MainActor
    final class QuickActionsViewModelTests {
        // perform(.cancellation) spawns a Task capturing self strongly, so only synchronous cases are leak-checked.
        private weak var sut: QuickActionsViewModel?

        init() {
            globalAppStateContainer.clearPersistence()
            // perform(.upgradeCoverage) reads the global ContractStore, so each test starts from an empty one.
            let contractStore: ContractStore = globalAppStateContainer.get()
            contractStore.activeContracts = []
        }

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func resetContractsAndExpectViewModelReleased() async {
            let contractStore: ContractStore = globalAppStateContainer.get()
            contractStore.activeContracts = []
            await delay(0.0000001)

            #expect(sut == nil, "performing a quick action must not leave a retain cycle behind")
        }

        @Test
        func performTravelInsurancePresentsTravelCertificate() async {
            do {
                let vm = QuickActionsViewModel()
                sut = vm

                vm.perform(.travelInsurance)

                #expect(vm.isTravelCertificatePresented)
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performChangeAddressPresentsChangeAddress() async {
            do {
                let vm = QuickActionsViewModel()
                sut = vm

                vm.perform(.changeAddress)

                #expect(vm.isChangeAddressPresented)
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performConnectPaymentsPresentsPayments() async {
            do {
                let vm = QuickActionsViewModel()
                sut = vm

                vm.perform(.connectPayments)

                #expect(vm.isPaymentsPresented)
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performEditInsuranceStoresEditContractActions() async {
            do {
                let vm = QuickActionsViewModel()
                sut = vm
                let wrapper = EditInsuranceActionsWrapper(quickActions: [.changeAddress, .editCoInsured])

                vm.perform(.editInsurance(actions: wrapper))

                #expect(vm.editContractActions == wrapper)
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performFirstVetCapturesPartnersFromTheQuickAction() async {
            do {
                let vm = QuickActionsViewModel()
                sut = vm
                let partners = [
                    FirstVetPartner(id: "first", description: "description", url: nil, title: "title"),
                    FirstVetPartner(id: "second", description: nil, url: "https://hedvig.com", title: nil),
                ]

                vm.perform(.firstVet(partners: partners))

                // The presented sheet renders these partners directly, so capturing them is the whole effect.
                #expect(vm.firstVetPartners?.partners == partners)
                #expect(vm.firstVetPartners?.id == "first,second")
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performFirstVetWithNoPartnersStillPresents() async {
            do {
                let vm = QuickActionsViewModel()
                sut = vm

                vm.perform(.firstVet(partners: []))

                #expect(vm.firstVetPartners?.partners == [])
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performSickAbroadStoresSickAbroadData() async {
            do {
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

                #expect(vm.sickAbroadData == deflection)
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performUpgradeCoveragePresentsChangeTierWithEligibleActiveContracts() async {
            do {
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
                #expect(vm.isChangeTierPresented?.source == .changeTier)
                #expect(vm.isChangeTierPresented?.contracts == [expectedContract])
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performUpgradeCoveragePresentsChangeTierWithNoContractsWhenStoreIsEmpty() async {
            do {
                let vm = QuickActionsViewModel()
                sut = vm

                vm.perform(.upgradeCoverage)

                #expect(vm.isChangeTierPresented?.source == .changeTier)
                #expect(vm.isChangeTierPresented?.contracts == [])
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func performRemoveAddonsDoesNotMutateState() async {
            do {
                let vm = QuickActionsViewModel()
                sut = vm

                vm.perform(.removeAddons)

                #expect(vm.editContractActions == nil)
                #expect(vm.isTravelCertificatePresented == false)
                #expect(vm.isChangeAddressPresented == false)
                #expect(vm.firstVetPartners == nil)
                #expect(vm.sickAbroadData == nil)
                #expect(vm.isChangeTierPresented == nil)
            }

            await resetContractsAndExpectViewModelReleased()
        }

        @Test
        func terminationConfigsKeepsOnlyContractsSupportingTermination() async {
            do {
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

                #expect(configs.map(\.contractId) == ["terminable-first", "terminable-second"])
                #expect(configs.map(\.contractDisplayName) == ["Home Insurance", "Dog Insurance"])
                #expect(configs.map(\.contractExposureName) == ["Apartment", "Bamse"])
            }

            await resetContractsAndExpectViewModelReleased()
        }

        // Intentionally uncovered perform(_:) cases -- their observable effect lives outside the view model:
        // - .editCoInsured / .editCoOwners: delegate to EditStakeholdersViewModel.start(stakeholderType:), which
        //   reads existing stakeholders and drives its own navigation -- heavy service mocking for no assertion
        //   the view model itself owns.
        // - .cancellation's async Task: TerminateInsuranceViewModel.start(with:) hits the network, and the Task
        //   captures self strongly, so it would outlive the test body. The part the view model owns -- which
        //   contracts become TerminationConfirmConfigs -- is covered synchronously by
        //   terminationConfigsKeepsOnlyContractsSupportingTermination.

        // Minimal Contract fixture; only the fields the view model reads vary between call sites.
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
    }
}
