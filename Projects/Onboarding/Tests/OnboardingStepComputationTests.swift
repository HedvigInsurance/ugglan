import Contracts
import CrossSell
import EditStakeholders
import Testing
import hCore

@testable import Onboarding

extension OnboardingDependencySuite {
    @MainActor
    final class OnboardingStepComputationTests {
        init() {
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
            FeatureFlags.shared.data = .mock(isAnalyticsEnabled: true)
        }

        @Test
        func staticStepsAlwaysPresent() {
            let steps = OnboardingStepList.compute(
                contracts: [],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(
                steps == [
                    .welcome,
                    .analyticsConsent,
                    .phoneNumber(phoneNumber: ""),
                    .theme,
                ]
            )
        }

        @Test
        func analyticsConsentStepHiddenWhenAnalyticsDisabled() {
            FeatureFlags.shared.data = .mock(isAnalyticsEnabled: false)
            let steps = OnboardingStepList.compute(
                contracts: [],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(steps.contains(.analyticsConsent) == false)
        }

        @Test
        func phoneNumberStepCarriesContactInfo() {
            let steps = OnboardingStepList.compute(
                contracts: [],
                isPaymentConnected: true,
                crossSells: [],
                contactInfo: .init(phone: "0735328847")
            )
            #expect(steps.contains(.phoneNumber(phoneNumber: "0735328847")))
        }

        @Test
        func inviteFriendStepShownWhenForeverDataExists() {
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
            #expect(steps.contains { $0.matches(.inviteFriend(discountCode: "", monthlyDiscountPerReferral: "")) })
        }

        @Test
        func inviteFriendStepHiddenWithoutForeverData() {
            let steps = OnboardingStepList.compute(
                contracts: [],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(
                steps.contains { $0.matches(.inviteFriend(discountCode: "", monthlyDiscountPerReferral: "")) } == false
            )
        }

        @Test
        func paymentStepShownWhenNotConnected() {
            let steps = OnboardingStepList.compute(
                contracts: [],
                isPaymentConnected: false,
                crossSells: []
            )
            #expect(steps.contains(.connectPayment(connectedProvider: nil)))
        }

        @Test
        func crossSellStepShownWhenCrossSellsExist() {
            let steps = OnboardingStepList.compute(
                contracts: [],
                isPaymentConnected: true,
                crossSells: [.mock]
            )
            #expect(steps.last == .crossSell([.mock]))
        }

        @Test
        func coInsuredStepShownWhenContractHasMissingCoInsured() {
            let contract = Self.makeContract(coInsured: [.init(needsMissingInfo: true)])
            let steps = OnboardingStepList.compute(
                contracts: [contract],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(steps.contains(.coInsured(contracts: [.init(contract: contract)])))
        }

        @Test
        func coInsuredStepHiddenWhenNoCoInsuredIsMissingInfo() {
            let contract = Self.makeContract(coInsured: [.init(needsMissingInfo: false)])
            let steps = OnboardingStepList.compute(
                contracts: [contract],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(steps.contains { $0.matches(.coInsured(contracts: [])) } == false)
        }

        @Test
        func coOwnersStepShownWhenContractHasMissingCoOwners() {
            let contract = Self.makeContract(coOwners: [.init(needsMissingInfo: true)])
            let steps = OnboardingStepList.compute(
                contracts: [contract],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(steps.contains(.coOwners(contracts: [.init(contract: contract)])))
        }

        @Test
        func coOwnersStepHiddenWhenNoCoOwnerIsMissingInfo() {
            let contract = Self.makeContract(coOwners: [.init(needsMissingInfo: false)])
            let steps = OnboardingStepList.compute(
                contracts: [contract],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(steps.contains { $0.matches(.coOwners(contracts: [])) } == false)
        }

        @Test
        func petChipIdsStepShownWithContractsWhenContractIsMissingPetChipId() {
            let contract = Self.makeContract(missingPetChipId: true)
            let steps = OnboardingStepList.compute(
                contracts: [contract],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(steps.contains(.petChipIds(contracts: [.init(contract: contract)])))
        }

        @Test
        func petChipIdsStepHiddenWhenNoContractIsMissingPetChipId() {
            let contract = Self.makeContract(missingPetChipId: false)
            let steps = OnboardingStepList.compute(
                contracts: [contract],
                isPaymentConnected: true,
                crossSells: []
            )
            #expect(steps.contains { $0.matches(.petChipIds(contracts: [])) } == false)
        }

        @Test
        func allStepsShownInOrderWhenEveryConditionApplies() {
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
            #expect(
                steps == [
                    .welcome,
                    .analyticsConsent,
                    .phoneNumber(phoneNumber: ""),
                    .coInsured(contracts: [.init(contract: contract)]),
                    .coOwners(contracts: [.init(contract: contract)]),
                    .petChipIds(contracts: [.init(contract: contract)]),
                    .theme,
                    .connectPayment(connectedProvider: nil),
                    .crossSell([.mock]),
                ]
            )
        }
    }
}

extension OnboardingDependencySuite.OnboardingStepComputationTests {
    /// Defaults for `Contract`'s 22-parameter init so tests only spell out the fields they exercise.
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
            isAnalyticsEnabled: isAnalyticsEnabled,
            isResumingOngoingShopSessionsEnabled: false
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
            webActionURL: "webActionURL",
            imageUrl: nil,
            buttonDescription: "buttonDescription"
        )
    }
}
