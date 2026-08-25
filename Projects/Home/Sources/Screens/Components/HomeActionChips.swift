import AppStateContainer
import Claims
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct HomeActionChips: View {
    @EnvironmentObject var navigationVm: HomeNavigationViewModel
    @AppObservedObject var store: ClaimsStore
    @InjectObservableObject var featureFlags: FeatureFlags

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            chipsRow
        }
        .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
            scrollView.clipsToBounds = false
        }
    }

    private var chipsRow: some View {
        hSection {
            HStack(spacing: .padding8) {
                chip(label: L10n.HomeTab.claimButtonText, style: .filled) {
                    navigationVm.claimsAutomationStartInput = .init(type: store.startClaimType)
                }

                if !featureFlags.isDemoMode {
                    chip(label: L10n.HomeTab.getHelp, style: .light) {
                        navigationVm.isHelpCenterPresented = true
                    }
                }

                chip(label: L10n.dashboardOpenChat, style: .light) {
                    navigationVm.router.push(HomeRouterAction.inbox)
                }
            }
        }
        .sectionContainerStyle(.transparent)
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
                button
                    .buttonStyle(.glassProminent)
                    .tint(hFillColor.Opaque.primary)

            case .light:
                button
                    .buttonStyle(.glass)
                    .tint(hBackgroundColor.primary)
            }
        } else {
            hButton(.medium, style == .filled ? .primary : .secondaryAlt, content: .init(title: label)) {
                action()
            }
            .hCustomButtonView {
                chipLable(label, style: style)
                    .padding(.horizontal, .padding4)
                    .padding(.top, .padding8)
                    .padding(.bottom, .padding6)
            }
            .hCustomButtonConerRadius(.cornerRadiusRounded)
            .hShadow(type: .light)
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
