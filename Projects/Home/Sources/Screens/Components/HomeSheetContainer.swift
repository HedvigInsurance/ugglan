import SwiftUI
import hCore
import hCoreUI

/// The pinned top of the home sheet: action chips floating over the hero plus the grabber on the
/// surface's rounded top edge. Pinned as a section header, the sheet content scrolls beneath it
/// and is clipped by the section body, so this view never hosts the content itself.
struct HomeSheetContainer: View {
    var body: some View {
        VStack(spacing: 0) {
            HomeActionChips()
            grabber
                .frame(maxWidth: .infinity)
                .background {
                    surfaceShape
                        .fill(hFillColor.Translucent.primary)
                        .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
                        .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
                        .clipShape(Rectangle())
                }
        }
    }

    private var surfaceShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: .cornerRadiusXXXL,
            topTrailingRadius: .cornerRadiusXXXL
        )
    }

    private var grabber: some View {
        Capsule()
            .fill(hSurfaceColor.Opaque.secondary)
            .frame(width: 40, height: 4)
            .padding(.top, .padding10)
            .padding(.bottom, .padding6)
            .accessibilityHidden(true)
    }
}

@MainActor private func setUpHomeSheetContainerPreview() {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
}

#Preview {
    setUpHomeSheetContainerPreview()

    return HomeSheetContainer()
        .environmentObject(HomeNavigationViewModel())
}
