import Contracts
import EditStakeholders
import XCTest
import hCore

@testable import Onboarding

final class OnboardingStepComputationTests: XCTestCase {
    func testStaticStepsAlwaysPresent() {
        let steps = OnboardingStepList.compute(contracts: [])
        XCTAssertEqual(
            steps,
            [
                .welcome,
                .analyticsConsent,
                .phoneNumber(phoneNumber: "", email: ""),
                .theme,
            ]
        )
    }

    func testPhoneNumberStepCarriesContactInfo() {
        let steps = OnboardingStepList.compute(
            contracts: [],
            contactInfo: .init(email: "demo@hedvig.com", phone: "0735328847")
        )
        XCTAssertTrue(steps.contains(.phoneNumber(phoneNumber: "0735328847", email: "demo@hedvig.com")))
    }

    func testCoInsuredStepShownWhenContractHasMissingCoInsured() {
        let contract = Self.makeContract(coInsured: [.init(needsMissingInfo: true)])
        let steps = OnboardingStepList.compute(contracts: [contract])
        XCTAssertTrue(steps.contains(.coInsured(contracts: [.init(contract: contract)])))
    }

    func testCoInsuredStepHiddenWhenNoCoInsuredIsMissingInfo() {
        let contract = Self.makeContract(coInsured: [.init(needsMissingInfo: false)])
        let steps = OnboardingStepList.compute(contracts: [contract])
        XCTAssertFalse(steps.contains { $0.matches(.coInsured(contracts: [])) })
    }

    func testCoOwnersStepShownWhenContractHasMissingCoOwners() {
        let contract = Self.makeContract(coOwners: [.init(needsMissingInfo: true)])
        let steps = OnboardingStepList.compute(contracts: [contract])
        XCTAssertTrue(steps.contains(.coOwners(contracts: [.init(contract: contract)])))
    }

    func testCoOwnersStepHiddenWhenNoCoOwnerIsMissingInfo() {
        let contract = Self.makeContract(coOwners: [.init(needsMissingInfo: false)])
        let steps = OnboardingStepList.compute(contracts: [contract])
        XCTAssertFalse(steps.contains { $0.matches(.coOwners(contracts: [])) })
    }

    func testPetChipIdsStepShownWithContractsWhenContractIsMissingPetChipId() {
        let contract = Self.makeContract(missingPetChipId: true)
        let steps = OnboardingStepList.compute(contracts: [contract])
        XCTAssertTrue(steps.contains(.petChipIds(contracts: [.init(contract: contract)])))
    }

    func testPetChipIdsStepHiddenWhenNoContractIsMissingPetChipId() {
        let contract = Self.makeContract(missingPetChipId: false)
        let steps = OnboardingStepList.compute(contracts: [contract])
        XCTAssertFalse(steps.contains { $0.matches(.petChipIds(contracts: [])) })
    }

    func testAllStepsShownInOrderWhenEveryConditionApplies() {
        let contract = Self.makeContract(
            coInsured: [.init(needsMissingInfo: true)],
            coOwners: [.init(needsMissingInfo: true)],
            missingPetChipId: true
        )
        let steps = OnboardingStepList.compute(contracts: [contract])
        XCTAssertEqual(
            steps,
            [
                .welcome,
                .analyticsConsent,
                .phoneNumber(phoneNumber: "", email: ""),
                .theme,
                .coInsured(contracts: [.init(contract: contract)]),
                .coOwners(contracts: [.init(contract: contract)]),
                .petChipIds(contracts: [.init(contract: contract)]),
            ]
        )
    }
}

extension OnboardingStepComputationTests {
    /// `Contract`'s memberwise init has 22 parameters; this factory supplies sensible
    /// defaults so gating tests only need to spell out the fields they exercise.
    fileprivate static func makeContract(
        coInsured: [Stakeholder] = [],
        coOwners: [Stakeholder] = [],
        missingPetChipId: Bool = false,
        terminationDate: String? = nil
    ) -> Contract {
        .init(
            id: "contractId",
            currentAgreement: nil,
            exposureDisplayName: "Home",
            exposureDisplayNameShort: "Home",
            masterInceptionDate: nil,
            terminationDate: terminationDate,
            supportsAddressChange: false,
            supportsCoInsured: true,
            supportsCoOwners: true,
            supportsTravelCertificate: false,
            supportsChangeTier: false,
            supportsTermination: false,
            upcomingChangedAgreement: nil,
            upcomingRenewal: nil,
            firstName: "First",
            lastName: "Last",
            ssn: nil,
            typeOfContract: .seApartmentRent,
            coInsured: coInsured,
            coOwners: coOwners,
            missingPetChipId: missingPetChipId
        )
    }
}
