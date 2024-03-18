import Foundation
import MarkdownKit
import SnapKit
import SwiftUI
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
        if let maxWidth = config.maxWidth {
            CustomTextViewRepresentable(
                config: config,
                fixedWidth: maxWidth,
                height: $height,
                width: $width
            )
            .frame(width: width, height: height)
        } else {
            GeometryReader { geo in
                Color.clear.background(
                    CustomTextViewRepresentable(
                        config: config,
                        fixedWidth: geo.size.width,
                        height: $height,
                        width: $width
                    )
                )
            }
            .frame(height: height)

        }
    }
}

struct CustomTextViewRepresentable: UIViewRepresentable {
    let config: CustomTextViewRepresentableConfig
    let fixedWidth: CGFloat
    @Binding private var height: CGFloat
    @Binding private var width: CGFloat
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    init(
        config: CustomTextViewRepresentableConfig,
        fixedWidth: CGFloat,
        height: Binding<CGFloat>,
        width: Binding<CGFloat>
    ) {
        self.config = config
        self.fixedWidth = fixedWidth
        _height = height
        _width = width
    }

    func makeUIView(context: Context) -> some UIView {
        let textView = CustomTextView(
            config: config,
            fixedWidth: fixedWidth,
            height: $height,
            width: $width,
            colorScheme: colorScheme
        )
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
    @Binding var width: CGFloat
    var colorScheme: ColorScheme
    init(
        config: CustomTextViewRepresentableConfig,
        fixedWidth: CGFloat,
        height: Binding<CGFloat>,
        width: Binding<CGFloat>,
        colorScheme: ColorScheme
    ) {
        _height = height
        _width = width
        self.config = config
        self.fixedWidth = fixedWidth
        self.textView = UITextView()
        self.colorScheme = colorScheme
        super.init(frame: .zero)
        self.addSubview(textView)
        configureTextView()
        setContent(from: config.text)
        calculateHeight()
        self.clipsToBounds = false
    }

    private func configureTextView() {
        self.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = [.address, .link, .phoneNumber]
        textView.clipsToBounds = false
        var linkTextAttributes = [NSAttributedString.Key: Any]()
        linkTextAttributes[.foregroundColor] = config.linkColor.colorFor(colorScheme, .base).color.uiColor()
        linkTextAttributes[.underlineColor] = config.linkColor.colorFor(colorScheme, .base).color.uiColor()
        if let linkUnderlineStyle = config.linkUnderlineStyle {
            linkTextAttributes[.underlineStyle] = linkUnderlineStyle.rawValue
        }
        textView.linkTextAttributes = linkTextAttributes
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-6)
            make.trailing.equalToSuperview().offset(6)
            make.top.equalToSuperview()
        }
        textView.textContainerInset = .zero
        textView.delegate = self
    }

    func setContent(from text: String) {
        configureTextView()
        let markdownParser = MarkdownParser(
            font: Fonts.fontFor(style: config.fontStyle),
            color: config.color.colorFor(colorScheme, .base).color.uiColor()
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
        let newSize = getSize()
        DispatchQueue.main.async { [weak self] in
            self?.height = newSize.height
            self?.width = newSize.width - 12
        }
    }

    private func getSize() -> CGSize {
        let newSize = textView.sizeThatFits(
            CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        )
        return newSize
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
    let maxWidth: CGFloat?
    let textAlignment: NSTextAlignment

    public init(
        text: Markdown,
        fontStyle: HFontTextStyle,
        color: any hColor,
        linkColor: any hColor,
        linkUnderlineStyle: NSUnderlineStyle?,
        maxWidth: CGFloat? = nil,
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
        self.maxWidth = maxWidth
    }
}
