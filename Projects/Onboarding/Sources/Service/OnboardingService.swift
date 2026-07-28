import AutomaticLog
import Foundation
import hCore

@MainActor
public class OnboardingService {
    @Inject var client: OnboardingClient

    public init() {}

    @Log
    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        try await client.getOnboardingSteps()
    }

    @Log
    public func updateContactInfo(phone: String) async throws {
        try await client.updateContactInfo(phone: phone)
    }
}
