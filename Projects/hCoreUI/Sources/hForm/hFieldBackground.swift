import SwiftUI

struct hFieldBackgroundModifier: ViewModifier {
    @Binding var animate: Bool
    @Binding var error: String?
    @Environment(\.hUseNewDesign) var hUseNewDesign
    func body(content: Content) -> some View {
        if hUseNewDesign {
            VStack(alignment: .leading, spacing: 0) {
                content
                    .padding(.horizontal, 16)
                    .background(getBackgroundColor())
                    .animation(.easeOut, value: animate)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 12, height: 12)))
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                content
                    .padding(.horizontal, 16)
                    .background(getBackgroundColor())
                    .animation(.easeOut, value: animate)
                    .clipShape(Squircle.default())
            }
        }

    }

    @hColorBuilder
    private func getBackgroundColor() -> some hColor {
        if animate {
            if error != nil {
                hColorScheme(light: hSignalColor.Amber.fill, dark: hAmberColor.amber300)
            } else {
                hColorScheme(light: hSignalColor.Green.fill, dark: hGrayscaleOpaqueColor.greyScale800)
            }
        } else {
            hSurfaceColor.Opaque.primary
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
                    Image(uiImage: HCoreUIAsset.warningTriangleFilled.image)
                        .foregroundColor(hSignalColor.Amber.element)
                    hText(errorMessage, style: .standardSmall)
                        .foregroundColor(hTextColor.Opaque.primary)
                }
                .padding(.top, 6)
                .padding(.horizontal, 6)
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
    @Binding var animate: Bool
    @Binding var error: String?
    @Binding var shouldMoveLabel: Bool
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hFieldSize) var size
    @Environment(\.hWithoutDisabledColor) var withoutDisabledColor
    @Environment(\.hFieldLockedState) var isLocked
    @Environment(\.hFontSize) var fontSize

    var body: some View {
        let sizeToScaleFrom = size == .large ? HFontTextStyle.title3.fontSize : HFontTextStyle.body1.fontSize
        let sizeToScaleTo = HFontTextStyle.footnote.fontSize
        let ratio = sizeToScaleTo / sizeToScaleFrom
        return hText(
            placeholder,
            style: size == .large ? .title3 : (fontSize == .body1 ? .standardSmall : .body1)
        )
        .foregroundColor(getTextColor())
        .scaleEffect(shouldMoveLabel ? ratio : 1, anchor: .leading)
        .frame(height: sizeToScaleFrom)
        .padding(.bottom, shouldMoveLabel ? (size == .large ? -0.5 : -1) : size == .large ? 21 : 16)
        .padding(.top, shouldMoveLabel ? (size == .large ? -1.5 : 0) : size == .large ? 21 : 16)
    }

    @hColorBuilder
    private func getTextColor() -> some hColor {
        if error != nil {
            hColorScheme(light: hSignalColor.Amber.text, dark: hTextColor.Opaque.secondary)
        } else if animate {
            hColorScheme(light: hSignalColor.Green.text, dark: hGrayscaleOpaqueColor.greyScale500)
        } else if isEnabled || withoutDisabledColor {
            hTextColor.Opaque.secondary
        } else if isLocked {
            hTextColor.Opaque.tertiary
        } else {
            hTextColor.Translucent.tertiary
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
