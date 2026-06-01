import Testing
import hCore

@testable import Contracts

struct ContractCanTerminateTests {
    @Test
    func canTerminateWhenSupportedAndNotTerminated() {
        let contract = makeContract(supportsTermination: true, terminationDate: nil)
        #expect(contract.canTerminate)
    }

    @Test
    func cannotTerminateWhenBackendDisallows() {
        let contract = makeContract(supportsTermination: false, terminationDate: nil)
        #expect(!contract.canTerminate)
    }

    @Test
    func cannotTerminateWhenAlreadyTerminated() {
        let contract = makeContract(supportsTermination: true, terminationDate: "2026-01-01")
        #expect(!contract.canTerminate)
    }

    @Test
    func cannotTerminateWhenBothDisallowedAndTerminated() {
        let contract = makeContract(supportsTermination: false, terminationDate: "2026-01-01")
        #expect(!contract.canTerminate)
    }

    private func makeContract(supportsTermination: Bool, terminationDate: String?) -> Contract {
        Contract(
            id: "id",
            currentAgreement: nil,
            exposureDisplayName: "",
            exposureDisplayNameShort: "",
            masterInceptionDate: nil,
            terminationDate: terminationDate,
            supportsAddressChange: false,
            supportsCoInsured: false,
            supportsCoOwners: false,
            supportsTravelCertificate: false,
            supportsChangeTier: false,
            supportsTermination: supportsTermination,
            upcomingChangedAgreement: nil,
            upcomingRenewal: nil,
            firstName: "",
            lastName: "",
            ssn: nil,
            typeOfContract: .seHouse,
            coInsured: [],
            coOwners: [],
            missingPetChipId: false,
        )
    }
}
