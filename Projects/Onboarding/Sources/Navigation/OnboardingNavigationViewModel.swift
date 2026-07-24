import SwiftUI
import hCore
import hCoreUI

@MainActor
class OnboardingNavigationViewModel: ObservableObject {
    let router = NavigationRouter()
    let onboardingService = OnboardingService()
    @Published var steps: [OnboardingStep] = [
        .welcome
    ]

    func advance(after step: OnboardingStep) {
        guard let index = steps.firstIndex(where: { $0.matches(step) }), index + 1 < steps.count else {
            router.dismiss()
            return
        }
        router.push(steps[index + 1])
    }
}
