import Foundation
import Onboarding
import Profile
import hCore

@MainActor
public class OnboardingClientOctopus: OnboardingClient {
    @Inject private var profileClient: ProfileClient

    public init() {}

    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        let memberDetails = try await profileClient.getMemberDetails()
        return OnboardingStepList.compute(
            contactInfo: ContactInfo(email: memberDetails.email ?? "", phone: memberDetails.phone ?? "")
        )
    }

    public func updateContactInfo(email: String, phone: String) async throws {
        _ = try await profileClient.update(email: email, phone: phone)
    }
}
