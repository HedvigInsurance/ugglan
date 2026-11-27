import Testing
import hCore

@testable import ContractsCore

// Pure value tests: they build contracts and touch no shared globals, so they stay top level.
@MainActor
struct EditTypeWithdrawalTests {
    @Test
    func getTypesWithWithdrawalSupportKeepsCancellation() {
        let contract = makeContract(supportsTermination: true, supportsWithdrawal: true)

        #expect(EditType.getTypes(for: contract) == [.cancellation])
    }

    @Test
    func getTypesWithWithdrawalSupportAddsChangeAddressBeforeCancellation() {
        let contract = makeContract(supportsTermination: true, supportsWithdrawal: true, supportsAddressChange: true)

        #expect(EditType.getTypes(for: contract) == [.changeAddress, .cancellation])
    }

    @Test
    func getTypesWithoutWithdrawalSupportOmitsChangeAddress() {
        let contract = makeContract(supportsTermination: true, supportsWithdrawal: false, supportsAddressChange: true)

        #expect(EditType.getTypes(for: contract) == [.cancellation])
    }

    @Test
    func getTypesWithoutTerminationOrWithdrawalReturnsNeither() {
        let contract = makeContract(supportsTermination: false, supportsWithdrawal: false)

        #expect(EditType.getTypes(for: contract).isEmpty)
    }

    @Test
    func asTerminationConfirmConfigForwardsWithdrawalSupport() {
        #expect(
            makeContract(supportsTermination: true, supportsWithdrawal: true).asTerminationConfirmConfig
                .supportsWithdrawal
        )
        #expect(
            !makeContract(supportsTermination: true, supportsWithdrawal: false).asTerminationConfirmConfig
                .supportsWithdrawal
        )
    }

    private func makeContract(
        supportsTermination: Bool,
        supportsWithdrawal: Bool,
        supportsAddressChange: Bool = false
    ) -> Contract {
        .init(
            id: "contract-123",
            currentAgreement: nil,
            exposureDisplayName: "Kungsgatan 1",
            exposureDisplayNameShort: "Kungsgatan 1",
            masterInceptionDate: "2026-11-20",
            terminationDate: nil,
            supportsAddressChange: supportsAddressChange,
            supportsCoInsured: false,
            supportsCoOwners: false,
            supportsTravelCertificate: false,
            supportsChangeTier: false,
            supportsTermination: supportsTermination,
            supportsWithdrawal: supportsWithdrawal,
            upcomingChangedAgreement: nil,
            upcomingRenewal: nil,
            firstName: "first",
            lastName: "last",
            ssn: nil,
            typeOfContract: .seApartmentBrf,
            coInsured: [],
            coOwners: [],
            missingPetChipId: false
        )
    }
}
