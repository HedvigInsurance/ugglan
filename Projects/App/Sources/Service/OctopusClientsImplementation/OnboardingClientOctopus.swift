import Contracts
import Foundation
import Onboarding
import Profile
import hCore

@MainActor
public class OnboardingClientOctopus: OnboardingClient {
    @Inject private var contractsClient: FetchContractsClient
    @Inject private var profileClient: ProfileClient

    public init() {}

    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        async let contractsStack = contractsClient.getContracts()
        let memberDetails = try await profileClient.getMemberDetails()
        return try await OnboardingStepList.compute(
            contracts: contractsStack.activeContracts + contractsStack.pendingContracts,
            contactInfo: ContactInfo(email: memberDetails.email ?? "", phone: memberDetails.phone ?? "")
        )
    }

    public func updateContactInfo(email: String, phone: String) async throws {
        _ = try await profileClient.update(email: email, phone: phone)
    }
}
