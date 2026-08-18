import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

/// Ugglan-only developer settings, intentionally not localized.
struct DevSettingsView: View {
    @AppObservedObject var devSettingsStore: DevSettingsStore
    @State private var showOnboardingOnNextLaunch = !OnboardingPresentationState.hasSeenOnboarding

    var body: some View {
        hForm {
            hSection {
                hRow {
                    hText("Submit claim flow animations")
                }
                .withSelectedAccessory(devSettingsStore.isSubmitClaimAnimationsEnabled)
                .onTap { [weak devSettingsStore] in
                    guard let devSettingsStore else { return }
                    devSettingsStore.setSubmitClaimAnimationsEnabled(
                        !devSettingsStore.isSubmitClaimAnimationsEnabled
                    )
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Submit claim flow animations")
                .accessibilityValue(devSettingsStore.isSubmitClaimAnimationsEnabled ? "On" : "Off")

                hRow {
                    hText("Show onboarding on next launch")
                }
                .withSelectedAccessory(showOnboardingOnNextLaunch)
                .onTap {
                    showOnboardingOnNextLaunch.toggle()
                    OnboardingPresentationState.hasSeenOnboarding = !showOnboardingOnNextLaunch
                    if showOnboardingOnNextLaunch {
                        AnalyticsConsent.reset()
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Show onboarding on next launch")
                .accessibilityValue(showOnboardingOnNextLaunch ? "On" : "Off")
            }
            .padding(.top, .padding8)
        }
    }
}

#Preview {
    DevSettingsView()
}
