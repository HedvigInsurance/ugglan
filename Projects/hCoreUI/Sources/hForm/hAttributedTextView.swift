import Foundation
import SwiftUI

public struct hAttributedTextView: View {
    let text: NSAttributedString
    @State var height: CGFloat = 20
    @State var width: CGFloat = 0

    public init(text: NSAttributedString) {
        self.text = text
    }
    public var body: some View {
        GeometryReader { geo in
            Color.clear.background(
                AttributedTextViewRepresentable(
                    fixedWidth: geo.size.width,
                    attributedString: text,
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
    @Binding private var height: CGFloat

    init(fixedWidth: CGFloat, attributedString: NSAttributedString, height: Binding<CGFloat>) {
        self.fixedWidth = fixedWidth
        self.attributedString = attributedString
        self._height = height
    }
    func makeUIView(context: Context) -> some UIView {
        AttributedUITextView(
            fixedWidth: fixedWidth,
            attributedString: attributedString,
            height: $height
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

    init(fixedWidth: CGFloat, attributedString: NSAttributedString, height: Binding<CGFloat>) {
        self._height = height
        self.fixedWidth = fixedWidth
        super.init(frame: .zero, textContainer: nil)
        self.attributedText = attributedString
        self.textContainerInset = .init(horizontalInset: 0, verticalInset: 0)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        updateHeight()
    }
    func updateHeight() {
        DispatchQueue.main.async { [weak self] in guard let self = self else { return }
            withAnimation {
                self.height = self.sizeThatFits(.init(width: self.fixedWidth, height: .infinity)).height
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
