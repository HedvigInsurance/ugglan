import Profile
import SwiftUI
import hCore

struct OnboardingAnalyticsScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel

    var body: some View {
        AnalyticsConsentScreen { _ in
            await delay(0.8)
            vm.advance(after: .analyticsConsent)
        }
        .hFormContentPosition(.center)
    }
}

#Preview {
    OnboardingAnalyticsScreen()
        .environmentObject(OnboardingNavigationViewModel())
}
