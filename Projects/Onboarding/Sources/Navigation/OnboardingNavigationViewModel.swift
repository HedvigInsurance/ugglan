import SwiftUI
import hCore
import hCoreUI

@MainActor
class OnboardingNavigationViewModel: ObservableObject {
    private static let hasBeenPresentedKey = "onboarding_has_been_presented"
    public static var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: hasBeenPresentedKey) == true
    }

    static func setOnboardingToSeen() {
        UserDefaults.standard.set(true, forKey: OnboardingNavigationViewModel.hasBeenPresentedKey)
    }

    let router = NavigationRouter()
    let onboardingService = OnboardingService()
    @Published var steps: [OnboardingStep] = [
        .welcome
    ]
    {
        didSet {
            progress = .init(currentStep: progress.currentStep, totalSteps: steps.count)
        }
    }
    @Published var progress = StepProgressModel(currentStep: 0, totalSteps: 0)

    func advance(after step: OnboardingStep) {
        guard let index = steps.firstIndex(where: { $0.matches(step) }), index + 1 < steps.count else {
            router.dismiss()
            OnboardingNavigationViewModel.setOnboardingToSeen()
            return
        }
        router.push(steps[index + 1])
    }

    func updateProgress() {
        let index = router.routeTypes.count
        withAnimation { progress = .init(currentStep: index + 1, totalSteps: steps.count) }
    }
}
