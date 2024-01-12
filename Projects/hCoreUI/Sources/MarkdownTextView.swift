import Flow
import Form
import Foundation
import MarkdownKit
import SnapKit
import SwiftUI
import UIKit
import hCore
import hGraphQL

public struct CustomTextViewRepresentable: UIViewRepresentable {
    private let text: String
    private let fixedWidth: CGFloat
    @Binding var height: CGFloat
    let onUrlClicked: (_ url: URL) -> Void
    public init(
        text: String,
        fixedWidth: CGFloat,
        height: Binding<CGFloat>,
        onUrlClicked: @escaping (_ url: URL) -> Void
    ) {
        self.text = text
        self.fixedWidth = fixedWidth
        _height = height
        self.onUrlClicked = onUrlClicked
    }
    public func makeUIView(context: Context) -> some UIView {
        let textView = CustomTextView(text: text, fixedWidth: fixedWidth, height: $height, onUrlClicked: onUrlClicked)
        return textView
    }
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

class CustomTextView: UIView, UITextViewDelegate {
    let textView: UITextView
    let fixedWidth: CGFloat
    let onUrlClicked: (_ url: URL) -> Void
    @Binding var height: CGFloat
    init(text: String, fixedWidth: CGFloat, height: Binding<CGFloat>, onUrlClicked: @escaping (_ url: URL) -> Void) {
        _height = height
        self.onUrlClicked = onUrlClicked
        self.fixedWidth = fixedWidth
        self.textView = UITextView()
        super.init(frame: .zero)
        self.addSubview(textView)
        configureTextView()
        setContent(from: text)
        calculateHeight()
    }

    private func configureTextView() {
        self.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = [.address, .link, .phoneNumber]
        let schema = ColorScheme(UITraitCollection.current.userInterfaceStyle) ?? .light
        let linkColor = hTextColor.primary.colorFor(schema, .base).color.uiColor()
        textView.linkTextAttributes = [
            .foregroundColor: linkColor,
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .underlineColor: linkColor,
        ]
        textView.backgroundColor = .clear
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-6)
            make.trailing.equalToSuperview().offset(6)
            make.bottom.top.equalToSuperview()
        }
        textView.textContainerInset = .zero
        textView.delegate = self
    }

    private func setContent(from text: String) {
        configureTextView()
        let markdownParser = MarkdownParser(
            font: Fonts.fontFor(style: .standardLarge),
            color: hTextColor.secondary.colorFor(.light, .base).color.uiColor()
        )

        let attributedString = markdownParser.parse(text)
        if !text.isEmpty {
            let mutableAttributedString = NSMutableAttributedString(
                attributedString: attributedString
            )
            textView.attributedText = mutableAttributedString
        }
    }

    private func calculateHeight() {
        let newHeight = getHeight()
        self.snp.makeConstraints { make in
            make.height.equalTo(newHeight)
            make.width.equalTo(fixedWidth)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.height = newHeight
        }
    }

    private func getHeight() -> CGFloat {
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        onUrlClicked(URL)

        let emailMasking = Masking(type: .email)
        if emailMasking.isValid(text: URL.absoluteString) {
            let emailURL = "mailto:" + URL.absoluteString
            if let url = Foundation.URL(string: emailURL) {
                UIApplication.shared.open(url)
            }
        }

        return false
    }
}
