import AppStateContainer
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
        async let crossSells = crossSellClient.getCrossSell(source: .insurances)
        async let foreverData = foreverClient.getMemberReferralInformation()
        let memberDetails = try await profileClient.getMemberDetails()
        return try await OnboardingStepList.compute(
            contracts: contractsStack.activeContracts + contractsStack.pendingContracts,
            isPaymentConnected: paymentStatus.status != .needsSetup,
            crossSells: crossSells.others,
            contactInfo: ContactInfo(phone: memberDetails.phone ?? ""),
            // Non-blocking: a failed referral fetch must not sink onboarding — the invite
            // step just renders without amount and share button.
            foreverData: try? foreverData
        )
    }

    public func updateContactInfo(phone: String) async throws {
        try await profileClient.update(phone: phone)
    }

    public func getCrossSells() async throws -> [CrossSell] {
        try await crossSellClient.getCrossSell(source: .insurances).others
    }

    public func getIsPaymentConnected() async throws -> Bool {
        let paymentStore: PaymentStore = globalAppStateContainer.get()
        await paymentStore.fetchPaymentStatus()
        if let paymentStatusData = paymentStore.paymentStatusData {
            return paymentStatusData.status != .needsSetup
        }
        return false
    }
}
