import Foundation

@MainActor
public protocol OnboardingClient {
    func getOnboardingSteps() async throws -> [OnboardingStep]
    func updateContactInfo(email: String, phone: String) async throws
}
