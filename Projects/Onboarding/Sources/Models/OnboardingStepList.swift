import Contracts
import CrossSell
import Forever
import Foundation
import hCore

public struct ContactInfo: Equatable, Hashable, Sendable {
    public let email: String
    public let phone: String

    public init(email: String, phone: String) {
        self.email = email
        self.phone = phone
    }
}

/// A contract surfaced in an onboarding step, plus onboarding-local added-state.
/// `missingData` is always true on init — cleared via the ViewModel's mark helpers once
/// the member adds the missing info during onboarding.
public struct OnboardingContract: Hashable, Identifiable, Sendable {
    public let contract: Contracts.Contract
    public var missingData: Bool

    public var id: String { contract.id }

    public init(contract: Contracts.Contract) {
        self.contract = contract
        self.missingData = true
    }
}

public enum OnboardingStepList {
    public static func compute(
        contracts: [Contracts.Contract],
        isPaymentConnected: Bool,
        crossSells: [CrossSell],
        contactInfo: ContactInfo = .init(email: "", phone: ""),
        foreverData: ForeverData? = nil,
        isConnectPaymentEnabled: Bool
    ) -> [OnboardingStep] {
        var steps: [OnboardingStep] = [
            .welcome,
            .analyticsConsent,
            .phoneNumber(phoneNumber: contactInfo.phone, email: contactInfo.email),
            .theme,
        ]
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
        if !isPaymentConnected, isConnectPaymentEnabled {
            steps.append(.connectPayment(isConnected: false))
        }
        if !crossSells.isEmpty {
            steps.append(.crossSell(crossSells))
        }
        return steps
    }
}
