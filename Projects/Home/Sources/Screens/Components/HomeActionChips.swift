import AppStateContainer
import Claims
import SwiftUI
import hCore
import hCoreUI

struct HomeActionChips: View {
    @EnvironmentObject var navigationVm: HomeNavigationViewModel
    @AppState var store: ClaimsStore
    @InjectObservableObject var featureFlags: FeatureFlags

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .padding8) {
                chip(title: L10n.HomeTab.claimButtonText, style: .filled) { [weak navigationVm] in
                    navigationVm?.claimsAutomationStartInput = .init(type: store.startClaimType)
                }

                if !featureFlags.isDemoMode {
                    chip(title: L10n.HomeTab.getHelp, style: .light) { [weak navigationVm] in
                        navigationVm?.isHelpCenterPresented = true
                    }
                }
                // TODO: Lokalise
                chip(title: "Contact us", style: .light) { [weak navigationVm] in
                    navigationVm?.router.push(HomeRouterAction.inbox)
                }
            }
            .padding(.horizontal, .padding16)
            .padding(.vertical, .padding8)
        }
    }

    private enum ChipStyle {
        case filled
        case light
    }

    private func chip(title: String, style: ChipStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            hText(title, style: .body1)
                .foregroundColor(style == .filled ? hTextColor.Opaque.negative : hTextColor.Opaque.primary)
                .padding(.horizontal, .padding16)
                .padding(.vertical, .padding12)
                .background {
                    switch style {
                    case .filled: Capsule().fill(hFillColor.Opaque.primary).hShadow(type: .light)
                    case .light: Capsule().fill(hBackgroundColor.primary).hShadow(type: .light)
                    }
                }
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })

    return HomeActionChips().environmentObject(HomeNavigationViewModel())
}
