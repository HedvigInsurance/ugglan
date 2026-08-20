import Contracts
import CrossSell
import Forever
import Foundation
import hCore

public struct ContactInfo: Equatable, Hashable, Sendable {
    public let phone: String

    public init(phone: String) {
        self.phone = phone
    }
}

/// A contract surfaced in an onboarding step, plus onboarding-local added-state.
/// `missingData` is always true on init — cleared via the ViewModel's mark helpers once
/// the member adds the missing info during onboarding.
public struct OnboardingContract: Hashable, Identifiable, Sendable {
    public let contract: Contracts.Contract
    public var missingData: Bool
    public var addedInfo: String?

    func getSubtitle() -> String {
        if let addedInfo {
            return [contract.exposureDisplayNameShort, addedInfo].displayName
        }
        if contract.supportsCoInsured {
            return L10n.onboardingNumberOfCoinsured(contract.coInsured.count)
        }
        if contract.supportsCoOwners {
            return L10n.onboardingNumberOfCoowners(contract.coOwners.count)
        }
        return contract.exposureDisplayNameShort
    }

    public var id: String { contract.id }

    public init(contract: Contracts.Contract) {
        self.contract = contract
        self.missingData = true
    }
}

public enum OnboardingStepList {
    @MainActor
    public static func compute(
        contracts: [Contracts.Contract],
        isPaymentConnected: Bool,
        crossSells: [CrossSell],
        contactInfo: ContactInfo = .init(phone: ""),
        foreverData: ForeverData? = nil
    ) -> [OnboardingStep] {
        var steps: [OnboardingStep] = [
            .welcome
        ]
        if Dependencies.featureFlags().isAnalyticsEnabled {
            steps.append(.analyticsConsent)
        }
        steps.append(.phoneNumber(phoneNumber: contactInfo.phone))

        let coInsuredContracts = contracts.filter(\.hasMissingCoInsured).map(OnboardingContract.init)
        if !coInsuredContracts.isEmpty {
            steps.append(.coInsured(contracts: coInsuredContracts))
        }
        let coOwnerContracts = contracts.filter(\.hasMissingCoOwners).map(OnboardingContract.init)
        if !coOwnerContracts.isEmpty {
            steps.append(.coOwners(contracts: coOwnerContracts))
        }
        let contractsMissingPetChipId = contracts.filter(\.missingPetChipId).map(OnboardingContract.init)
        if !contractsMissingPetChipId.isEmpty {
            steps.append(.petChipIds(contracts: contractsMissingPetChipId))
        }
        if let foreverData {
            steps.append(
                .inviteFriend(
                    discountCode: foreverData.discountCode,
                    monthlyDiscountPerReferral: foreverData.monthlyDiscountPerReferral.formattedAmount
                )
            )
        }
        if !isPaymentConnected {
            steps.append(.connectPayment(isConnected: false))
        }
        steps.append(.theme)
        if !crossSells.isEmpty {
            steps.append(.crossSell(crossSells))
        }
        return steps
    }
}
