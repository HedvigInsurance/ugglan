import Contracts
import EditStakeholders
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
        .handleEditStakeholders(with: vm.editStakeholdersVm)
        .handleMissingChipIds(input: $vm.missingPetChipIdInput)
    }

    @ViewBuilder
    private func stepDestination(for step: OnboardingStep) -> some View {
        Group {
            switch step {
            case .welcome: OnboardingWelcomeScreen()
            case .analyticsConsent: OnboardingAnalyticsScreen()
            case let .phoneNumber(phoneNumber, email):
                OnboardingPhoneScreen(phoneNumber: phoneNumber, email: email)
            case .theme: OnboardingThemeScreen()
            case .coInsured: OnboardingMissingInfoScreen(type: .coInsured)
            case .coOwners: OnboardingMissingInfoScreen(type: .coOwner)
            case .petChipIds: OnboardingMissingInfoScreen(type: .petChipIds)
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
