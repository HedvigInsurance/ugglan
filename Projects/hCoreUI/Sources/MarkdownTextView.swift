import Flow
import Form
import Foundation
import MarkdownKit
import SnapKit
import SwiftUI
import UIKit
import hCore
import hGraphQL

public struct MarkdownView: View {
    private let text: String
    @State private var height: CGFloat = 20
    @State private var width: CGFloat = 0
    private let fontStyle: HFontTextStyle
    private let textAlignment: NSTextAlignment
    let onUrlClicked: (_ url: URL) -> Void
    public init(
        text: String,
        fontStyle: HFontTextStyle,
        textAlignment: NSTextAlignment,
        onUrlClicked: @escaping (_ url: URL) -> Void
    ) {
        self.text = text
        self.fontStyle = fontStyle
        self.textAlignment = textAlignment
        self.onUrlClicked = onUrlClicked
    }
    public var body: some View {
        GeometryReader { geo in
            Color.clear.background(
                CustomTextViewRepresentable(
                    text: text,
                    fixedWidth: geo.size.width,
                    height: $height,
                    fontStyle: fontStyle,
                    textAlignment: textAlignment,
                    onUrlClicked: { url in
                        onUrlClicked(url)
                    }
                )
            )
        }
        .frame(height: height)
    }
}

public struct CustomTextViewRepresentable: UIViewRepresentable {
    private let text: String
    private let fixedWidth: CGFloat
    private let fontStyle: HFontTextStyle
    private let textAlignment: NSTextAlignment
    @Binding private var height: CGFloat
    @SwiftUI.Environment(\.colorScheme) var colorScheme

    let onUrlClicked: (_ url: URL) -> Void
    public init(
        text: String,
        fixedWidth: CGFloat,
        height: Binding<CGFloat>,
        fontStyle: HFontTextStyle,
        textAlignment: NSTextAlignment = .left,
        onUrlClicked: @escaping (_ url: URL) -> Void
    ) {
        self.text = text
        self.fixedWidth = fixedWidth
        self.fontStyle = fontStyle
        _height = height
        self.textAlignment = textAlignment
        self.onUrlClicked = onUrlClicked
    }
    public func makeUIView(context: Context) -> some UIView {
        let textView = CustomTextView(
            text: text,
            fixedWidth: fixedWidth,
            fontStyle: fontStyle,
            height: $height,
            textAlignment: textAlignment,
            onUrlClicked: onUrlClicked
        )
        return textView
    }
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if let uiView = uiView as? CustomTextView {
            uiView.setContent(from: text)
        }
    }
}

class CustomTextView: UIView, UITextViewDelegate {
    private let textView: UITextView
    private let fixedWidth: CGFloat
    private let fontStyle: HFontTextStyle
    private let textAlignment: NSTextAlignment
    private let onUrlClicked: (_ url: URL) -> Void
    @Binding private var height: CGFloat

    init(
        text: String,
        fixedWidth: CGFloat,
        fontStyle: HFontTextStyle,
        height: Binding<CGFloat>,
        textAlignment: NSTextAlignment,
        onUrlClicked: @escaping (_ url: URL) -> Void
    ) {
        _height = height
        self.fontStyle = fontStyle
        self.onUrlClicked = onUrlClicked
        self.fixedWidth = fixedWidth
        self.textView = UITextView()
        self.textAlignment = textAlignment
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

    func setContent(from text: String) {
        configureTextView()
        let schema = ColorScheme(UITraitCollection.current.userInterfaceStyle) ?? .light
        let markdownParser = MarkdownParser(
            font: Fonts.fontFor(style: fontStyle),
            color: hTextColor.secondary.colorFor(schema, .base).color.uiColor()
        )
        let attributedString = markdownParser.parse(text)
        if !text.isEmpty {
            let mutableAttributedString = NSMutableAttributedString(
                attributedString: attributedString
            )
            textView.attributedText = mutableAttributedString
            textView.textAlignment = textAlignment
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

        let emailMasking = Masking(type: .email)
        if emailMasking.isValid(text: URL.absoluteString) {
            let emailURL = "mailto:" + URL.absoluteString
            if let url = Foundation.URL(string: emailURL) {
                UIApplication.shared.open(url)
            }
        } else {
            onUrlClicked(URL)
        }

        return false
    }
}
