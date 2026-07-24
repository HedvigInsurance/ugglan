import SwiftUI
import hCore
import hCoreUI

struct OnboardingThemeScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel
    @State private var themeId: String? = ThemeOption.current.id

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(ThemeOption.allCases) { theme in
                        hRadioField(
                            id: theme.id,
                            leftView: {
                                HStack(spacing: .padding8) {
                                    theme.image
                                        .padding(.padding8)
                                        .background(hSurfaceColor.Translucent.secondary)
                                        .cornerRadius(.cornerRadiusS)
                                    VStack(alignment: .leading) {
                                        hText(theme.displayName, style: .heading1)
                                            .foregroundColor(hTextColor.Opaque.primary)
                                        hText(subtitle(for: theme), style: .label)
                                            .foregroundColor(hTextColor.Translucent.secondary)
                                    }
                                }
                                .asAnyView
                            },
                            selected: $themeId
                        )
                        .hFieldSize(.small)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .hUseCheckbox
        }
        .hFormTitle(
            title: .init(.small, .body1, L10n.settingsThemeDialogTitle, alignment: .leading),
            subTitle: .init(
                .small,
                .body1,
                "Customize the look of the app",
                alignment: .leading
            )
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding16) {
                    hText("You can change these settings later", style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                    hContinueButton { vm.advance(after: .theme) }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .onChange(of: themeId) { newValue in
            if let theme = ThemeOption.allCases.first(where: { $0.id == newValue }) {
                ThemeOption.current = theme
                theme.apply()
            }
        }
    }

    private func subtitle(for theme: ThemeOption) -> String {
        switch theme {
        case .system: return "Uses your phone's setting"  // TODO: L10n
        case .light: return "Set light mode"  // TODO: L10n
        case .dark: return "Set dark mode"  // TODO: L10n
        }
    }
}

#Preview {
    OnboardingThemeScreen()
        .environmentObject(OnboardingNavigationViewModel())
}
