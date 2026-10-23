import SwiftUI

struct hFieldBackgroundModifier: ViewModifier {
    @Binding var animate: Bool
    @Binding var error: String?
    @Environment(\.isEnabled) var enabled
    @Environment(\.hBackgroundOption) var backgroundOption

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(.horizontal, .padding16)
                .background(getBackgroundColor())
                .animation(.easeOut, value: animate)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        }
    }

    @hColorBuilder
    private func getBackgroundColor() -> some hColor {
        if animate {
            if error != nil {
                hSignalColor.Amber.fill
            } else {
                hSurfaceColor.Translucent.secondary
            }
        } else {
            hSurfaceColor.Translucent.primary
        }
    }
}

extension View {
    public func addFieldBackground(animate: Binding<Bool>, error: Binding<String?>) -> some View {
        modifier(hFieldBackgroundModifier(animate: animate, error: error))
    }
}

struct hFieldErrorModifier: ViewModifier {
    @Binding var animate: Bool
    @Binding var error: String?

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content
            if let errorMessage = error {
                HStack {
                    hText(errorMessage, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
                .padding(.leading, .padding16)
                .padding(.top, .padding4)
                .padding(.bottom, .padding8)
                .foregroundColor(hSignalColor.Amber.fill)
            }
        }
    }
}

extension View {
    public func addFieldError(animate: Binding<Bool>, error: Binding<String?>) -> some View {
        modifier(hFieldErrorModifier(animate: animate, error: error))
    }
}

struct hFieldContainer<Content: View>: View {
    let placeholder: String
    let customLabelOffset: Bool?
    @Binding var animate: Bool
    @Binding var error: String?
    @Binding var shouldMoveLabel: Bool
    @ViewBuilder var textField: () -> Content

    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.hFieldSize) var size
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hBackgroundOption) var backgroundOption
    @Environment(\.hFieldMultiline) var isMultiline

    var body: some View {
        // Multiline fields are taller than the label, so pin both to the top to keep the label on the first line
        ZStack(alignment: isMultiline ? .topLeading : .leading) {
            ZStack(alignment: .leading) {
                if isMultiline {
                    // Box as tall as a single line field, so the label is centered like in a single line field.
                    // A single line UITextField is ~2pt taller than its font's line height, hence the extra padding.
                    hText(" ", style: size.labelFont)
                        .padding(.vertical, 1)
                        .hidden()
                        .accessibilityHidden(true)
                }
                hFieldLabel(
                    placeholder: placeholder,
                    animate: $animate,
                    error: $error,
                    shouldMoveLabel: $shouldMoveLabel
                )
            }
            .offset(y: (customLabelOffset ?? shouldMoveLabel) ? labelOffset : 0)

            textField()
                .offset(y: (customLabelOffset ?? shouldMoveLabel) ? fieldOffset : 0)
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
    }

    private var isAccessibilitySize: Bool {
        dynamicTypeSize >= .accessibility1
    }

    private var topPadding: CGFloat {
        if isAccessibilitySize {
            if dynamicTypeSize > .accessibility3 {
                return 30
            } else {
                return 16
            }
        } else {
            return size.topPadding
        }
    }

    private var bottomPadding: CGFloat {
        if isAccessibilitySize {
            return topPadding + 2
        } else {
            return size.bottomPadding
        }
    }

    private var labelOffset: CGFloat {
        if isAccessibilitySize {
            if dynamicTypeSize > .accessibility3 {
                return -40
            } else {
                return -20
            }
        } else {
            return size.labelOffset
        }
    }

    private var fieldOffset: CGFloat {
        if isAccessibilitySize {
            if dynamicTypeSize > .accessibility3 {
                return 40
            } else {
                return 20
            }
        } else {
            return size.fieldOffset
        }
    }
}

struct hFieldLabel: View {
    let placeholder: String
    let useScaleEffect: Bool
    @Binding var animate: Bool
    @Binding var error: String?
    @Binding var shouldMoveLabel: Bool
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hFieldSize) var size
    @Environment(\.hBackgroundOption) var backgroundOption

    init(
        placeholder: String,
        useScaleEffect: Bool = true,
        animate: Binding<Bool>,
        error: Binding<String?>,
        shouldMoveLabel: Binding<Bool>
    ) {
        self.placeholder = placeholder
        self.useScaleEffect = useScaleEffect
        _animate = animate
        _error = error
        _shouldMoveLabel = shouldMoveLabel
    }

    var body: some View {
        hText(
            placeholder
        )
        .hTextStyle(shouldMoveLabel ? .label : font)
        .padding(.leading, 1)
        .foregroundColor(getTextColor())
    }

    private var font: HFontTextStyle {
        switch size {
        case .small, .medium:
            return .body1
        case .large, .extraLarge:
            return .body2
        }
    }

    @hColorBuilder
    private func getTextColor() -> some hColor {
        if error != nil && animate {
            hSignalColor.Amber.text
        } else if animate {
            hTextColor.Translucent.secondary
        } else if isEnabled || backgroundOption.contains(.withoutDisabled) {
            hTextColor.Translucent.secondary
        } else if backgroundOption.contains(.locked) {
            hTextColor.Translucent.secondary
        } else if shouldMoveLabel, !isEnabled {
            hTextColor.Translucent.secondary
        } else {
            hTextColor.Translucent.disabled
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var value: String?
    @Previewable @State var error: String?
    @Previewable @State var animate: Bool = false
    @Previewable @State var shouldMoveLabel: Bool = true

    hFieldLabel(
        placeholder: "PLACE",
        animate: $animate,
        error: $error,
        shouldMoveLabel: $shouldMoveLabel
    )
    .hFieldSize(.small)
    .addFieldBackground(animate: $animate, error: $error)
    .addFieldError(animate: $animate, error: $error)
}
