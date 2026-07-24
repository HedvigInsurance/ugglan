import Foundation
import hCore

@MainActor
public class OnboardingClientDemo: OnboardingClient {
    public init() {}

    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        await delay(1)
        return OnboardingClientDemo.getSteps()
    }

    public func updateContactInfo(email: String, phone: String) async throws {}

    static func getSteps() -> [OnboardingStep] {
        OnboardingStepList.compute(
            contactInfo: .init(email: "demo@hedvig.com", phone: "0735328847")
        )
    }
}
