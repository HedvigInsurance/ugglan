import SwiftUI
import hCore
import hCoreUI

struct AddonOptionRow<Trailing: View>: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    var isDisabled: Bool = false
    @ViewBuilder let trailingView: () -> Trailing
    let onTap: (() -> Void)?

    init(
        title: String,
        subtitle: String,
        isSelected: Bool,
        isDisabled: Bool = false,
        trailingView: @escaping () -> Trailing,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.trailingView = trailingView
        self.onTap = onTap
    }

    var body: some View {
        Group {
            HStack(alignment: .top) {
                CheckmarkSquare(isSelected: isSelected, color: checkmarkColor)

                VStack(alignment: .leading, spacing: .padding4) {
                    HStack {
                        hText(title).foregroundColor(titleColor)
                        Spacer()
                        trailingView()
                    }
                    hText(subtitle, style: .label).foregroundColor(subTitleColor)
                }
            }
            .padding(.horizontal, .padding18)
            .padding(.top, .padding19)
            .padding(.bottom, .padding21)
        }
        .containerShape(.rect)
        .background(hSurfaceColor.Opaque.primary)
        .cornerRadius(.cornerRadiusL)
        .accessibilityElement(children: .combine)
        .accessibilityHint(hint)
        .addAccessibilityAction(for: onTap, isSelected: isSelected)
    }

    private var hint: String {
        let status: String = {
            if isDisabled && isSelected {
                return L10n.voiceoverOptionSelected
            } else if isSelected {
                return L10n.voiceoverOptionSelected
            }
            return L10n.a11YOptionNotSelected
        }()
        return status
    }

    @hColorBuilder
    private var checkmarkColor: some hColor {
        if isSelected && !isDisabled {
            hSignalColor.Green.element
        } else {
            hGrayscaleTranslucent.greyScaleTranslucent300
        }
    }

    @hColorBuilder
    private var titleColor: some hColor {
        if isDisabled { hTextColor.Translucent.secondary } else { hTextColor.Opaque.primary }
    }

    @hColorBuilder
    private var subTitleColor: some hColor {
        if isDisabled { hTextColor.Translucent.secondary } else { hTextColor.Opaque.secondary }
    }
}

private struct CheckmarkSquare<Color: hColor>: View {
    let isSelected: Bool
    let color: Color

    var body: some View {
        Image(systemName: isSelected ? "square.fill" : "square")
            .resizable()
            .foregroundColor(color)
            .font(.title2)
            .frame(width: 24, height: 24)
            .overlay {
                if isSelected {
                    hCoreUIAssets.checkmark.swiftUIImage
                        .foregroundColor(hSurfaceColor.Opaque.primary)
                }
            }
    }
}

extension View {
    @ViewBuilder
    fileprivate func addAccessibilityAction(for action: (() -> Void)?, isSelected: Bool) -> some View {
        if let action {
            self
                .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { action() } }
                .accessibilityAddTraits(.isButton)
                .accessibilityAction {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        action()
                    }
                    Task {
                        await delay(0.25)
                        UIAccessibility.post(
                            notification: .announcement,
                            argument: isSelected ? L10n.a11YOptionNotSelected : L10n.voiceoverOptionSelected
                        )
                    }
                }
        } else {
            self
        }
    }
}
