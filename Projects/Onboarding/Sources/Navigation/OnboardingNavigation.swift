import SwiftUI
import hCore
import hCoreUI

struct OnboardingNavigation: View {
    @StateObject private var vm = OnboardingNavigationViewModel()

    init(steps: [OnboardingStep]) {
        let vm = OnboardingNavigationViewModel()
        vm.steps = steps
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        hNavigationStack(
            router: vm.router,
            options: [],
            tracking: OnboardingStep.welcome
        ) {
            stepDestination(for: .welcome)
                .routerDestination(for: OnboardingStep.self) { step in
                    stepDestination(for: step)
                }
        }
        .environmentObject(vm)
    }

    @ViewBuilder
    private func stepDestination(for step: OnboardingStep) -> some View {
        Group {
            switch step {
            case .welcome: OnboardingWelcomeScreen()
            case .analyticsConsent: OnboardingAnalyticsScreen()
            case let .phoneNumber(phoneNumber, email):
                OnboardingPhoneScreen(phoneNumber: phoneNumber, email: email)
            }
        }
        .withDismissButton()
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> OnboardingClient in OnboardingClientDemo() })
    let steps = OnboardingClientDemo.getSteps()
    return OnboardingNavigation(steps: steps)
}
