import AppStateContainer
import Combine
import Contracts
import CrossSell
import EditStakeholders
import Payment
import SwiftUI
import hCore
import hCoreUI

struct OnboardingNavigation: View {
    @State private var vm = OnboardingNavigationViewModel()

    init(steps: [OnboardingStep]) {
        let vm = OnboardingNavigationViewModel()
        vm.steps = steps
        _vm = State(wrappedValue: vm)
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
                .addStepProgressBar(with: $vm.progress)
        }
        .environment(vm)
        .handleEditStakeholders(with: vm.editStakeholdersVm)
        .handleMissingChipIds(input: $vm.missingPetChipIdInput)
    }

    @ViewBuilder
    private func stepDestination(for step: OnboardingStep) -> some View {
        Group {
            switch step {
            case .welcome: OnboardingWelcomeScreen()
            case .analyticsConsent: OnboardingAnalyticsScreen()
            case let .phoneNumber(phoneNumber):
                OnboardingPhoneScreen(phoneNumber: phoneNumber)
            case .theme: OnboardingThemeScreen()
            case .coInsured: OnboardingMissingInfoScreen(type: .coInsured)
            case .coOwners: OnboardingMissingInfoScreen(type: .coOwner)
            case .petChipIds: OnboardingMissingInfoScreen(type: .petChipIds)
            case let .inviteFriend(discountCode, monthlyDiscountPerReferral):
                OnboardingInviteScreen(
                    discountCode: discountCode,
                    monthlyDiscountPerReferral: monthlyDiscountPerReferral
                )
            case .connectPayment: OnboardingConnectPaymentScreen()
            case .crossSell: OnboardingCrossSellScreen()
            }
        }
        .withDismissButton {
            OnboardingPresentationState.hasSeenOnboarding = true
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> OnboardingClient in OnboardingClientDemo() })
    let steps = OnboardingClientDemo.getSteps()
    return OnboardingNavigation(steps: steps)
}
