import SwiftUI

struct hFieldBackgroundModifier: ViewModifier {
    @Binding var animate: Bool
    @Binding var error: String?

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
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
            if let errorMessage = error {
                HStack {

                    Image(uiImage: HCoreUIAsset.warningFilledTriangle.image)
                        .foregroundColor(hAmberColorNew.amber600)
                    hText(errorMessage, style: .footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                .padding(.top, 6)
                .padding(.horizontal, 6)
                .foregroundColor(hLabelColorNew.warning)
            }
        }
    }

    @hColorBuilder
    private func getBackgroundColor() -> some hColor {
        if error != nil {
            hBackgroundColorNew.inputBackgroundWarning
        } else if animate {
            hBackgroundColorNew.inputBackgroundActive
        } else {
            hBackgroundColorNew.inputBackground
        }
    }
}
extension View {
    func addFieldBackground(animate: Binding<Bool>, error: Binding<String?>) -> some View {
        modifier(hFieldBackgroundModifier(animate: animate, error: error))
    }
}

struct hFieldLabel: View {
    let placeholder: String
    @Binding var animate: Bool
    @Binding var error: String?
    @Binding var shouldMoveLabel: Bool

    var body: some View {
        let sizeToScaleFrom = HFontTextStyleNew.title3.uifontTextStyleNew.pointSize
        let sizeToScaleTo = HFontTextStyleNew.footnote.uifontTextStyleNew.pointSize
        let ratio = sizeToScaleTo / sizeToScaleFrom
        let padding = HFontTextStyleNew.title3.uifontLineHeightDifference * 15
        return hTextNew(placeholder, style: .title3)
            .scaleEffect(shouldMoveLabel ? ratio : 1, anchor: .leading)
            .foregroundColor(getTextColor())
            .padding(.bottom, shouldMoveLabel ? 1 : padding)
            .padding(.top, shouldMoveLabel ? 0 : padding)

    }

    @hColorBuilder
    private func getTextColor() -> some hColor {
        if error != nil {
            hLabelColorNew.warning
        } else if animate {
            hLabelColorNew.active
        } else {
            hLabelColorNew.secondary
        }
    }
}
