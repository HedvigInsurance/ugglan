import SwiftUI

struct hFieldBackgroundModifier: ViewModifier {
    @Binding var animate: Bool
    @Binding var error: String?

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if #available(iOS 15.0, *) {
                content
                    .padding(.horizontal, 16)
                    .background(getBackgroundColor())
                    .animation(.easeOut, value: animate)
                    .clipShape(Squircle.default())

            } else {
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
                hColorScheme(light: hSignalColor.amberFill, dark: hAmberColor.amber300)
            } else {
                hColorScheme(light: hSignalColor.greenFill, dark: hGrayscaleColor.greyScale800)
            }
        } else {
            hFillColor.opaqueOne
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
                        .foregroundColor(hSignalColor.amberElement)
                    hText(errorMessage, style: .standardSmall)
                        .foregroundColor(hTextColor.primary)
                }
                .padding(.top, 6)
                .padding(.horizontal, 6)
                .foregroundColor(hSignalColor.amberFill)
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

    var body: some View {
        let sizeToScaleFrom = size == .large ? HFontTextStyle.title3.fontSize : HFontTextStyle.standard.fontSize
        let sizeToScaleTo = HFontTextStyle.footnote.fontSize
        let ratio = sizeToScaleTo / sizeToScaleFrom
        return hText(placeholder, style: size == .large ? .title3 : .standard)
            .foregroundColor(getTextColor())
            .scaleEffect(shouldMoveLabel ? ratio : 1, anchor: .leading)
            .frame(height: sizeToScaleFrom)
            .padding(.bottom, shouldMoveLabel ? (size == .large ? -0.5 : -1) : size == .large ? 21 : 16)
            .padding(.top, shouldMoveLabel ? (size == .large ? -1.5 : 0) : size == .large ? 21 : 16)
    }

    @hColorBuilder
    private func getTextColor() -> some hColor {
        if error != nil {
            hColorScheme(light: hSignalColor.amberText, dark: hTextColor.secondary)
        } else if animate {
            hColorScheme(light: hSignalColor.greenText, dark: hGrayscaleColor.greyScale500)
        } else if isEnabled || withoutDisabledColor {
            hTextColor.secondary
        } else {
            hTextColor.disabled
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
