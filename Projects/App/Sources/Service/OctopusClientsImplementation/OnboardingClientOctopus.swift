import Contracts
import CrossSell
import Forever
import Foundation
import Onboarding
import Payment
import Profile
import hCore

@MainActor
public class OnboardingClientOctopus: OnboardingClient {
    @Inject private var contractsClient: FetchContractsClient
    @Inject private var paymentClient: hPaymentClient
    @Inject private var crossSellClient: CrossSellClient
    @Inject private var profileClient: ProfileClient
    @Inject private var foreverClient: ForeverClient

    public init() {}

    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        async let contractsStack = contractsClient.getContracts()
        async let paymentStatus = paymentClient.getPaymentStatusData()
        async let crossSells = crossSellClient.getCrossSell(source: .insurances, contractId: nil)
        async let foreverData = foreverClient.getMemberReferralInformation()
        let memberDetails = try await profileClient.getMemberDetails()
        return try await OnboardingStepList.compute(
            contracts: contractsStack.activeContracts + contractsStack.pendingContracts,
            isPaymentConnected: paymentStatus.status != .needsSetup,
            crossSells: crossSells.others,
            contactInfo: ContactInfo(email: memberDetails.email ?? "", phone: memberDetails.phone ?? ""),
            // Non-blocking: a failed referral fetch must not sink onboarding — the invite
            // step just renders without amount and share button.
            foreverData: try? foreverData,
            isConnectPaymentEnabled: Dependencies.featureFlags().isConnectPaymentEnabled
        )
    }

    public func updateContactInfo(email: String, phone: String) async throws {
        _ = try await profileClient.update(email: email, phone: phone)
    }

    public func getCrossSells() async throws -> [CrossSell] {
        try await crossSellClient.getCrossSell(source: .insurances, contractId: nil).others
    }

    public func getIsPaymentConnected() async throws -> Bool {
        try await paymentClient.getPaymentStatusData().status != .needsSetup
    }
}
