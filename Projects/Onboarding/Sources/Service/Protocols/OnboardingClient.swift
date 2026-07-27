import Foundation

@MainActor
public protocol OnboardingClient {
    func getOnboardingSteps() async throws -> [OnboardingStep]
}
