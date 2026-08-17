import AppStateContainer
import Claims
import SwiftUI
import hCore
import hCoreUI

struct HomeActionChips: View {
    @EnvironmentObject var navigationVm: HomeNavigationViewModel
    @AppState var store: ClaimsStore
    @InjectObservableObject var featureFlags: FeatureFlags
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if #available(iOS 26.0, *) {
                GlassEffectContainer { chipsRow }  // TODO: combines glass too much?
            } else {
                chipsRow
            }
        }
    }

    private var chipsRow: some View {
        HStack(spacing: .padding8) {
            chip(label: L10n.HomeTab.claimButtonText, style: .filled) {
                navigationVm.claimsAutomationStartInput = .init(type: store.startClaimType)
            }

            if !featureFlags.isDemoMode {
                chip(label: L10n.HomeTab.getHelp, style: .light) {
                    navigationVm.isHelpCenterPresented = true
                }
            }
            // TODO: Lokalise
            chip(label: "Contact us", style: .light) {
                navigationVm.router.push(HomeRouterAction.inbox)
            }
        }
        .padding(.horizontal, .padding16)
        .padding(.bottom, .padding16)
    }

    private enum ChipStyle {
        case filled
        case light
    }

    @ViewBuilder private func chip(label: String, style: ChipStyle, action: @escaping () -> Void) -> some View {
        if #available(iOS 26.0, *) {
            let button = Button(action: action) { chipLable(label, style: style) }
                .buttonBorderShape(.capsule)
                .controlSize(.large)

            switch style {
            case .filled:
                button.buttonStyle(.glassProminent)
                    .tint(hFillColor.Opaque.primary.colorFor(colorScheme, .base).color)
            case .light:
                button.buttonStyle(.glass)
            }
        } else {
            Button(action: action) {
                chipLable(label, style: style)
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

    private func chipLable(_ label: String, style: ChipStyle) -> some View {
        hText(label, style: .body1)
            .foregroundColor(style == .filled ? hTextColor.Opaque.negative : hTextColor.Opaque.primary)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })

    return HomeActionChips().environmentObject(HomeNavigationViewModel())
}
