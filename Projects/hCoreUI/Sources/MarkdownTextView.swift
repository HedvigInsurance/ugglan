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
    let config: CustomTextViewRepresentableConfig
    @Binding var height: CGFloat
    public init(
        text: Markdown,
        fixedWidth: CGFloat,
        height: Binding<CGFloat>,
        onUrlClicked: @escaping (_ url: URL) -> Void
    ) {
        let schema = ColorScheme(UITraitCollection.current.userInterfaceStyle) ?? .light
        let linkColor = hTextColor.primary.colorFor(schema, .base).color.uiColor()
        let textColor = hTextColor.secondary.colorFor(.light, .base).color.uiColor()
        config = .init(
            text: text,
            fixedWidth: fixedWidth,
            fontStyle: .standardLarge,
            color: textColor,
            linkColor: linkColor,
            linkUnderlineStyle: .thick,
            onUrlClicked: { url in
                onUrlClicked(url)
            }
        )
        _height = height
    }

    public init(
        config: CustomTextViewRepresentableConfig,
        height: Binding<CGFloat>
    ) {
        self.config = config
        _height = height
    }

    public func makeUIView(context: Context) -> some UIView {
        let textView = CustomTextView(config: config, height: $height)
        return textView
    }
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

class CustomTextView: UIView, UITextViewDelegate {
    let config: CustomTextViewRepresentableConfig
    let textView: UITextView
    @Binding var height: CGFloat
    init(config: CustomTextViewRepresentableConfig, height: Binding<CGFloat>) {
        _height = height
        self.config = config
        self.textView = UITextView()
        super.init(frame: .zero)
        self.addSubview(textView)
        configureTextView()
        setContent(from: config.text)
        calculateHeight()
    }

    private func configureTextView() {
        self.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = [.address, .link, .phoneNumber]
        textView.linkTextAttributes = [
            .foregroundColor: config.linkColor,
            .underlineColor: config.linkColor,
        ]
        if let linkUnderlineStyle = config.linkUnderlineStyle {
            textView.linkTextAttributes[.underlineStyle] = linkUnderlineStyle
        }

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
            font: Fonts.fontFor(style: config.fontStyle),
            color: config.color
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
            make.width.equalTo(config.fixedWidth)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.height = newHeight
        }
    }

    private func getHeight() -> CGFloat {
        let newSize = textView.sizeThatFits(CGSize(width: config.fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {

        let emailMasking = Masking(type: .email)
        if emailMasking.isValid(text: URL.absoluteString) {
            let emailURL = "mailto:" + URL.absoluteString
            if let url = Foundation.URL(string: emailURL) {
                UIApplication.shared.open(url)
            }
        } else {
            config.onUrlClicked(URL)
        }

        return false
    }
}

public struct CustomTextViewRepresentableConfig {
    let text: Markdown
    let fixedWidth: CGFloat
    let fontStyle: HFontTextStyle
    let color: UIColor
    let linkColor: UIColor
    let linkUnderlineStyle: NSUnderlineStyle?
    let onUrlClicked: (_ url: URL) -> Void

    public init(
        text: Markdown,
        fixedWidth: CGFloat,
        fontStyle: HFontTextStyle,
        color: UIColor,
        linkColor: UIColor,
        linkUnderlineStyle: NSUnderlineStyle?,
        onUrlClicked: @escaping (_: URL) -> Void
    ) {
        self.text = text
        self.fixedWidth = fixedWidth
        self.fontStyle = fontStyle
        self.color = color
        self.linkColor = linkColor
        self.linkUnderlineStyle = linkUnderlineStyle
        self.onUrlClicked = onUrlClicked
    }
}
