import Foundation
import hCore

@MainActor
public class OnboardingClientDemo: OnboardingClient {
    public init() {}

    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        await delay(1)
        return OnboardingClientDemo.getSteps()
    }

    static func getSteps() -> [OnboardingStep] {
        OnboardingStepList.compute()
    }
}
