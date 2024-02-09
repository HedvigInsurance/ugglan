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
    private let config: CustomTextViewRepresentableConfig
    @State private var height: CGFloat = 20
    @State private var width: CGFloat = 0
    public init(
        config: CustomTextViewRepresentableConfig
    ) {
        self.config = config
    }
    public var body: some View {
        GeometryReader { geo in
            Color.clear.background(
                CustomTextViewRepresentable(
                    config: config,
                    fixedWidth: geo.size.width,
                    height: $height
                )
            )
        }
        .frame(height: height)
    }
}

struct CustomTextViewRepresentable: UIViewRepresentable {
    let config: CustomTextViewRepresentableConfig
    let fixedWidth: CGFloat
    @Binding private var height: CGFloat
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    init(
        config: CustomTextViewRepresentableConfig,
        fixedWidth: CGFloat,
        height: Binding<CGFloat>
    ) {
        self.config = config
        self.fixedWidth = fixedWidth
        _height = height
    }

    func makeUIView(context: Context) -> some UIView {
        let textView = CustomTextView(config: config, fixedWidth: fixedWidth, height: $height)
        return textView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let uiView = uiView as? CustomTextView {
            uiView.setContent(from: config.text)
        }
    }
}

class CustomTextView: UIView, UITextViewDelegate {
    let config: CustomTextViewRepresentableConfig
    let fixedWidth: CGFloat
    let textView: UITextView
    @Binding var height: CGFloat
    init(config: CustomTextViewRepresentableConfig, fixedWidth: CGFloat, height: Binding<CGFloat>) {
        _height = height
        self.config = config
        self.fixedWidth = fixedWidth
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
        let schema = ColorScheme.init(UITraitCollection.current.userInterfaceStyle) ?? .light
        var linkTextAttributes = [NSAttributedString.Key: Any]()
        linkTextAttributes[.foregroundColor] = config.linkColor.colorFor(schema, .base).color.uiColor()
        linkTextAttributes[.underlineColor] = config.linkColor.colorFor(schema, .base).color.uiColor()
        if let linkUnderlineStyle = config.linkUnderlineStyle {
            linkTextAttributes[.underlineStyle] = linkUnderlineStyle.rawValue
        }
        textView.linkTextAttributes = linkTextAttributes

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
        let schema = ColorScheme.init(UITraitCollection.current.userInterfaceStyle) ?? .light
        let markdownParser = MarkdownParser(
            font: Fonts.fontFor(style: config.fontStyle),
            color: config.color.colorFor(schema, .base).color.uiColor()
        )
        let attributedString = markdownParser.parse(text)
        if !text.isEmpty {
            let mutableAttributedString = NSMutableAttributedString(
                attributedString: attributedString
            )
            textView.attributedText = mutableAttributedString
            textView.textAlignment = config.textAlignment
        }
    }

    private func calculateHeight() {
        let newHeight = getHeight()
        DispatchQueue.main.async { [weak self] in
            self?.height = newHeight
        }
    }

    private func getHeight() -> CGFloat {
        let newSize = textView.sizeThatFits(
            CGSize(width: fixedWidth + 12, height: CGFloat.greatestFiniteMagnitude)
        )
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
    let fontStyle: HFontTextStyle
    let color: any hColor
    let linkColor: any hColor
    let linkUnderlineStyle: NSUnderlineStyle?
    let onUrlClicked: (_ url: URL) -> Void
    let textAlignment: NSTextAlignment

    public init(
        text: Markdown,
        fontStyle: HFontTextStyle,
        color: any hColor,
        linkColor: any hColor,
        linkUnderlineStyle: NSUnderlineStyle?,
        textAlignment: NSTextAlignment = .left,
        onUrlClicked: @escaping (_: URL) -> Void
    ) {
        self.text = text
        self.fontStyle = fontStyle
        self.color = color
        self.linkColor = linkColor
        self.linkUnderlineStyle = linkUnderlineStyle
        self.textAlignment = textAlignment
        self.onUrlClicked = onUrlClicked
    }
}
