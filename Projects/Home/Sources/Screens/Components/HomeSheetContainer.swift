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
                        .fill(hBackgroundColor.primary)
                        .hShadow(type: .light)
                }
        }
    }

    private var surfaceShape: hRoundedRectangle {
        hRoundedRectangle(cornerRadius: .cornerRadiusXXL, corners: [.topLeft, .topRight])
    }
    
    private var grabber: some View {
        Capsule()
            .fill(hSurfaceColor.Opaque.secondary)
            .frame(width: 40, height: 4)
            .padding(.vertical, .padding10)
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
