import SwiftUI
import hCore
import hCoreUI

struct AddonOptionRow<Trailing: View>: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    var isDisabled: Bool = false
    @ViewBuilder let trailingView: () -> Trailing
    var onTap: () -> Void = {}

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
        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { onTap() } }
        .accessibilityAction { onTap() }
        .accessibilityHint(L10n.voiceoverPressTo)  // TODO: fix hint
        .background(hSurfaceColor.Opaque.primary)
        .cornerRadius(.cornerRadiusL)
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
