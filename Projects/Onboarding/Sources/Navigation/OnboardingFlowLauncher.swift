import AppStateContainer
import Combine
import Contracts
import CrossSell
import EditStakeholders
import Payment
import SwiftUI
import hCore
import hCoreUI

extension View {
    public func handleOnboarding() -> some View {
        self.modifier(OnboardingFlowLauncher())
    }
}

private struct OnboardingFlowLauncher: ViewModifier {
    @State var onboardingStepsWrapper: OnboardingStepsWrapper?

    public func body(content: Content) -> some View {
        content
            .modally(
                item: $onboardingStepsWrapper,
                options: .constant(.alwaysOpenOnTop)
            ) { stepsWrapper in
                OnboardingNavigation(steps: stepsWrapper.steps)
            }
            .task {
                guard !OnboardingNavigationViewModel.hasSeenOnboarding else { return }
                let service = OnboardingService()
                if let steps = try? await service.getOnboardingSteps() {
                    onboardingStepsWrapper = .init(id: UUID().uuidString, steps: steps)
                }
            }
    }
}

private struct OnboardingStepsWrapper: Equatable, Identifiable {
    let id: String
    let steps: [OnboardingStep]
}
