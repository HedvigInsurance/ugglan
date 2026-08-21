import Contracts
import CrossSell
import EditStakeholders
import XCTest
import hCore

@testable import Onboarding

@MainActor
final class OnboardingStepComputationTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        FeatureFlags.shared.data = .mock(isAnalyticsEnabled: true)
    }

    override func tearDown() async throws {
        FeatureFlags.shared.data = .mock(isAnalyticsEnabled: false)
        try await super.tearDown()
    }

    func testStaticStepsAlwaysPresent() {
        let steps = OnboardingStepList.compute(
            contracts: [],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertEqual(
            steps,
            [
                .welcome,
                .analyticsConsent,
                .phoneNumber(phoneNumber: ""),
                .theme,
            ]
        )
    }

    func testAnalyticsConsentStepHiddenWhenAnalyticsDisabled() {
        FeatureFlags.shared.data = .mock(isAnalyticsEnabled: false)
        let steps = OnboardingStepList.compute(
            contracts: [],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertFalse(steps.contains(.analyticsConsent))
    }

    func testPhoneNumberStepCarriesContactInfo() {
        let steps = OnboardingStepList.compute(
            contracts: [],
            isPaymentConnected: true,
            crossSells: [],
            contactInfo: .init(phone: "0735328847")
        )
        XCTAssertTrue(steps.contains(.phoneNumber(phoneNumber: "0735328847")))
    }

    func testInviteFriendStepShownWhenForeverDataExists() {
        let steps = OnboardingStepList.compute(
            contracts: [],
            isPaymentConnected: true,
            crossSells: [],
            foreverData: .init(
                grossAmount: .init(amount: "100", currency: "SEK"),
                netAmount: .init(amount: "90", currency: "SEK"),
                otherDiscounts: nil,
                discountCode: "CODE",
                monthlyDiscount: .init(amount: "10", currency: "SEK"),
                referrals: [],
                referredBy: nil,
                monthlyDiscountPerReferral: .init(amount: "10", currency: "SEK")
            )
        )
        XCTAssertTrue(steps.contains { $0.matches(.inviteFriend(discountCode: "", monthlyDiscountPerReferral: "")) })
    }

    func testInviteFriendStepHiddenWithoutForeverData() {
        let steps = OnboardingStepList.compute(
            contracts: [],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertFalse(steps.contains { $0.matches(.inviteFriend(discountCode: "", monthlyDiscountPerReferral: "")) })
    }

    func testPaymentStepShownWhenNotConnected() {
        let steps = OnboardingStepList.compute(
            contracts: [],
            isPaymentConnected: false,
            crossSells: []
        )
        XCTAssertTrue(steps.contains(.connectPayment(isConnected: false)))
    }

    func testCrossSellStepShownWhenCrossSellsExist() {
        let steps = OnboardingStepList.compute(
            contracts: [],
            isPaymentConnected: true,
            crossSells: [.mock]
        )
        XCTAssertEqual(steps.last, .crossSell([.mock]))
    }

    func testCoInsuredStepShownWhenContractHasMissingCoInsured() {
        let contract = Self.makeContract(coInsured: [.init(needsMissingInfo: true)])
        let steps = OnboardingStepList.compute(
            contracts: [contract],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertTrue(steps.contains(.coInsured(contracts: [.init(contract: contract)])))
    }

    func testCoInsuredStepHiddenWhenNoCoInsuredIsMissingInfo() {
        let contract = Self.makeContract(coInsured: [.init(needsMissingInfo: false)])
        let steps = OnboardingStepList.compute(
            contracts: [contract],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertFalse(steps.contains { $0.matches(.coInsured(contracts: [])) })
    }

    func testCoOwnersStepShownWhenContractHasMissingCoOwners() {
        let contract = Self.makeContract(coOwners: [.init(needsMissingInfo: true)])
        let steps = OnboardingStepList.compute(
            contracts: [contract],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertTrue(steps.contains(.coOwners(contracts: [.init(contract: contract)])))
    }

    func testCoOwnersStepHiddenWhenNoCoOwnerIsMissingInfo() {
        let contract = Self.makeContract(coOwners: [.init(needsMissingInfo: false)])
        let steps = OnboardingStepList.compute(
            contracts: [contract],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertFalse(steps.contains { $0.matches(.coOwners(contracts: [])) })
    }

    func testPetChipIdsStepShownWithContractsWhenContractIsMissingPetChipId() {
        let contract = Self.makeContract(missingPetChipId: true)
        let steps = OnboardingStepList.compute(
            contracts: [contract],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertTrue(steps.contains(.petChipIds(contracts: [.init(contract: contract)])))
    }

    func testPetChipIdsStepHiddenWhenNoContractIsMissingPetChipId() {
        let contract = Self.makeContract(missingPetChipId: false)
        let steps = OnboardingStepList.compute(
            contracts: [contract],
            isPaymentConnected: true,
            crossSells: []
        )
        XCTAssertFalse(steps.contains { $0.matches(.petChipIds(contracts: [])) })
    }

    func testAllStepsShownInOrderWhenEveryConditionApplies() {
        let contract = Self.makeContract(
            coInsured: [.init(needsMissingInfo: true)],
            coOwners: [.init(needsMissingInfo: true)],
            missingPetChipId: true
        )
        let steps = OnboardingStepList.compute(
            contracts: [contract],
            isPaymentConnected: false,
            crossSells: [.mock]
        )
        XCTAssertEqual(
            steps,
            [
                .welcome,
                .analyticsConsent,
                .phoneNumber(phoneNumber: ""),
                .coInsured(contracts: [.init(contract: contract)]),
                .coOwners(contracts: [.init(contract: contract)]),
                .petChipIds(contracts: [.init(contract: contract)]),
                .connectPayment(isConnected: false),
                .theme,
                .crossSell([.mock]),
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
    ) -> Contracts.Contract {
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

extension FeatureData {
    fileprivate static func mock(isAnalyticsEnabled: Bool) -> FeatureData {
        .init(
            isUpdateNecessary: false,
            isSubmitClaimEnabled: false,
            osVersionTooLow: false,
            emailPreferencesEnabled: false,
            isDemoMode: false,
            isAddonsRemovalFromMovingFlowEnabled: false,
            isNewConversationFromInboxEnabled: false,
            isPuppyGuideEnabled: false,
            isResumeClaimEnabled: false,
            isOnboardingEnabled: true,
            isTerminationRedirectionEnabled: false,
            isAnalyticsEnabled: isAnalyticsEnabled
        )
    }
}

extension CrossSell {
    fileprivate static var mock: CrossSell {
        .init(
            id: "cross-sell-id",
            title: "title",
            description: "description",
            buttonTitle: "buttonTitle",
            imageUrl: nil,
            buttonDescription: "buttonDescription"
        )
    }
}
