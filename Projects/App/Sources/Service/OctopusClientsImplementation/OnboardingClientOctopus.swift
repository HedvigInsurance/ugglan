import Foundation
import Onboarding
import hCore

@MainActor
public class OnboardingClientOctopus: OnboardingClient {
    public init() {}

    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        OnboardingStepList.compute()
    }
}
