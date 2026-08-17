import Profile
import SwiftUI
import hCore

struct OnboardingAnalyticsScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel

    var body: some View {
        AnalyticsConsentScreen(showsGraphic: true) { _ in
            await delay(0.8)
            vm.advance(after: .analyticsConsent)
        }
    }
}

#Preview {
    OnboardingAnalyticsScreen()
        .environmentObject(OnboardingNavigationViewModel())
}
