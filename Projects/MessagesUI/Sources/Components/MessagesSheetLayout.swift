import SwiftUI
import hCore
import hCoreUI

/// Shared layout of the Messages sheets: title, subtitle, content and full-width buttons (an optional primary one
/// above a secondary one).
/// Presented with the system `.sheet`, sized to its content, and scrolls only when the content is taller than the
/// sheet, e.g. at the largest text sizes.
struct MessagesSheetLayout<Content: View>: View {
    let title: String
    let subtitle: String
    /// Nil hides the primary button, e.g. when picking an option applies it straight away.
    var primaryTitle: String?
    let secondaryTitle: String
    var onPrimary: () -> Void = {}
    let onSecondary: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var contentHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .padding24) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(title, style: .heading2)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .accessibilityAddTraits(.isHeader)
                    hText(subtitle, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                content()
                buttons
            }
            .padding(.horizontal, .padding16)
            .padding(.top, .padding32)
            .padding(.bottom, .padding16)
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self, of: \.size.height) {
                contentHeight = $0.isFinite ? $0 : 0
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        // `.medium` until the first measurement lands.
        .presentationDetents(contentHeight > 0 ? [.height(contentHeight)] : [.medium])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var buttons: some View {
        VStack(spacing: .padding8) {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: .padding8) {
                    VStack(spacing: .padding8) {
                        if let primaryTitle {
                            glassButton(primaryTitle, style: .prominent, action: onPrimary)
                        }
                        glassButton(secondaryTitle, style: .regular, action: onSecondary)
                    }
                }
            } else {
                if let primaryTitle {
                    hButton(.large, .primary, content: .init(title: primaryTitle)) { onPrimary() }
                }
                hButton(.large, .ghost, content: .init(title: secondaryTitle)) { onSecondary() }
            }
        }
        .hButtonTakeFullWidth(true)
    }

    private func glassButton(
        _ title: String,
        style: MessagesGlassButtonStyle,
        action: @escaping () -> Void
    ) -> some View {
        SwiftUI.Button(action: action) {
            hText(title, style: .body1)
                .foregroundColor(style.labelColor)
                .frame(maxWidth: .infinity, minHeight: .padding40)
                .contentShape(Capsule())
        }
        .controlSize(.large)
        .messagesGlassButton(style)
    }
}
