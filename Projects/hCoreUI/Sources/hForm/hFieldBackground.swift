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
                hSurfaceColor.Opaque.secondary
            }
        } else {
            if backgroundOption.contains(.translucent) {
                if backgroundOption.contains(.negative) {
                    hFillColor.Translucent.negative
                } else {
                    hFillColor.Translucent.primary
                }
            } else {
                if backgroundOption.contains(.negative) {
                    hFillColor.Opaque.negative
                } else if backgroundOption.contains(.secondary) {
                    hSurfaceColor.Opaque.secondary
                } else {
                    hSurfaceColor.Opaque.primary
                }
            }
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
        self._animate = animate
        self._error = error
        self._shouldMoveLabel = shouldMoveLabel
    }

    var body: some View {
        let sizeToScaleFrom = size.labelFont.fontSize
        let sizeToScaleTo = HFontTextStyle.label.fontSize
        let ratio = sizeToScaleTo / sizeToScaleFrom
        return hText(
            placeholder
        )
        .hTextStyle(useScaleEffect ? font : (shouldMoveLabel ? .label : font))
        .padding(.leading, 1)
        .foregroundColor(getTextColor())
        .scaleEffect(useScaleEffect ? (shouldMoveLabel ? ratio : 1) : 1, anchor: .leading)
    }

    private var font: HFontTextStyle {
        switch size {
        case .small, .medium:
            return .body1
        case .large:
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
            hTextColor.Translucent.disabled
        } else if shouldMoveLabel && !isEnabled {
            hTextColor.Translucent.secondary
        } else {
            hTextColor.Translucent.disabled
        }
    }
}

struct hFieldLabel_Previews: PreviewProvider {
    @State static var value: String?
    @State static var error: String?
    @State static var animate: Bool = false
    @State static var shouldMoveLabel: Bool = true
    static var previews: some View {
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
}
