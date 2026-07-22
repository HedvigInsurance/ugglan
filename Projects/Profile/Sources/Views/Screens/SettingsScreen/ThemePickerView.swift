import SwiftUI
import hCore
import hCoreUI

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State var themeId: String? = ThemeOption.current.id

    var body: some View {
        hForm {
            VStack(spacing: .padding8) {
                hSection {
                    VStack(spacing: .padding4) {
                        ForEach(ThemeOption.allCases) { theme in
                            hRadioField(
                                id: theme.id,
                                leftView: {
                                    hText(theme.displayName, style: .heading1)
                                        .foregroundColor(hTextColor.Opaque.primary)
                                        .asAnyView
                                },
                                selected: $themeId
                            )
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.generalCloseButton)
                ) {
                    dismiss()
                }
            }
            .padding(.top, .padding16)
            .sectionContainerStyle(.transparent)
            .hWithoutDivider
        }
        .onChange(of: themeId) { newValue in
            if let theme = ThemeOption.allCases.first(where: { $0.id == newValue }) {
                ThemeOption.current = theme
                theme.apply()
            }
        }
    }
}

#Preview {
    ThemePickerView()
}
