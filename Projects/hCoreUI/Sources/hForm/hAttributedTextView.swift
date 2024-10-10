import Foundation
import SwiftUI

public struct hAttributedTextView: View {
    let text: NSAttributedString
    let useSecondaryColor: Bool
    @State var height: CGFloat = 20
    @State var width: CGFloat = 0

    public init(text: NSAttributedString, useSecondaryColor: Bool? = false) {
        self.text = text
        self.useSecondaryColor = useSecondaryColor ?? false
    }
    public var body: some View {
        GeometryReader { geo in
            Color.clear.background(
                AttributedTextViewRepresentable(
                    fixedWidth: geo.size.width,
                    attributedString: text,
                    useSecondaryColor: useSecondaryColor,
                    height: $height
                )
            )
        }
        .frame(height: height)
    }
}

private struct AttributedTextViewRepresentable: UIViewRepresentable {
    private let fixedWidth: CGFloat
    private let attributedString: NSAttributedString
    private let useSecondaryColor: Bool
    @Binding private var height: CGFloat

    init(fixedWidth: CGFloat, attributedString: NSAttributedString, useSecondaryColor: Bool, height: Binding<CGFloat>) {
        self.fixedWidth = fixedWidth
        self.attributedString = attributedString
        self.useSecondaryColor = useSecondaryColor
        self._height = height
    }
    func makeUIView(context: Context) -> some UIView {
        AttributedUITextView(
            fixedWidth: fixedWidth,
            attributedString: attributedString,
            height: $height,
            useSecondaryColor: useSecondaryColor
        )
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let uiView = uiView as? AttributedUITextView {
            uiView.updateHeight()
        }

    }
}

private class AttributedUITextView: UITextView, UITextViewDelegate {
    private let fixedWidth: CGFloat
    @Binding private var height: CGFloat

    init(fixedWidth: CGFloat, attributedString: NSAttributedString, height: Binding<CGFloat>, useSecondaryColor: Bool) {
        self._height = height
        self.fixedWidth = fixedWidth
        super.init(frame: .zero, textContainer: nil)
        self.attributedText = attributedString
        self.textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        self.backgroundColor = .clear
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        self.textColor = getTextColor(useSecondaryColor: useSecondaryColor)
        self.isUserInteractionEnabled = false
        updateHeight()
    }
    func updateHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            withAnimation {
                self.height = self.sizeThatFits(.init(width: self.fixedWidth, height: .infinity)).height
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getTextColor(useSecondaryColor: Bool) -> UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        if useSecondaryColor {
            return hTextColor.Opaque.secondary.colorFor(colorScheme, .base).color.uiColor()
        } else {
            return hTextColor.Opaque.primary.colorFor(colorScheme, .base).color.uiColor()
        }
    }
}
