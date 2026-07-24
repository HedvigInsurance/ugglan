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
    public func updateContactInfo(email: String, phone: String) async throws {
        try await client.updateContactInfo(email: email, phone: phone)
    }

    @Log
    public func getIsPaymentConnected() async throws -> Bool {
        try await client.getIsPaymentConnected()
    }
}
