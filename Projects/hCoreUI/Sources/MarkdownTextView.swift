import Foundation
import MarkdownKit
import SnapKit
import SwiftUI
import hCore

public struct MarkdownView: View {
    private let config: CustomTextViewRepresentableConfig
    @State private var height: CGFloat = 20
    @State private var width: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme

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
            .frame(maxWidth: maxWidth)
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
    @Environment(\.hEnvironmentAccessibilityLabel) var accessibilityLabel
    @Environment(\.sizeCategory) var sizeCategory

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

    func makeUIView(context _: Context) -> UIView {
        // wrapping the text view with a view to avoid issues with SwiftUI and UITextView
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let textView = CustomTextView(
            config: config,
            fixedWidth: fixedWidth,
            height: $height,
            width: $width,
            colorScheme: colorScheme
        )
        view.addSubview(textView)
        textView.accessibilityLabel = accessibilityLabel
        textView.setContent(from: config.text)
        textView.calculateHeight()
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context _: Context) {
        if let textView = uiView.subviews.first as? CustomTextView {
            textView.colorScheme = colorScheme
            textView.setContent(from: config.text)
            textView.calculateHeight()
            if let accessibilityLabel {
                textView.accessibilityLabel = accessibilityLabel
            }
        }
    }
}

@MainActor
private struct EnvironmentAccessibilityLabel: @preconcurrency EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    public var hEnvironmentAccessibilityLabel: String? {
        get { self[EnvironmentAccessibilityLabel.self] }
        set { self[EnvironmentAccessibilityLabel.self] = newValue }
    }
}

extension View {
    public func hEnvironmentAccessibilityLabel(_ label: String?) -> some View {
        environment(\.hEnvironmentAccessibilityLabel, label)
    }
}

class CustomTextView: UITextView, UITextViewDelegate {
    let config: CustomTextViewRepresentableConfig
    let fixedWidth: CGFloat
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
        self.colorScheme = colorScheme
        super.init(frame: .zero, textContainer: nil)
        configureTextView()
        snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(fixedWidth)
        }
    }

    func configureTextView() {
        backgroundColor = .clear
        isEditable = false
        isUserInteractionEnabled = true
        isScrollEnabled = false
        isSelectable = true
        dataDetectorTypes = [.address, .link, .phoneNumber]
        accessibilityTraits = .staticText
        var linkTextAttributes = [NSAttributedString.Key: Any]()
        linkTextAttributes[.foregroundColor] = config.linkColor.colorFor(colorScheme, .base).color.uiColor()
        linkTextAttributes[.underlineColor] = config.linkColor.colorFor(colorScheme, .base).color.uiColor()
        if let linkUnderlineStyle = config.linkUnderlineStyle {
            linkTextAttributes[.underlineStyle] = linkUnderlineStyle.rawValue
        }
        self.linkTextAttributes = linkTextAttributes
        textContainerInset = .zero
        delegate = self
    }

    func setContent(from text: String) {
        let markdownParser = MarkdownParser(
            font: Fonts.fontFor(style: config.fontStyle),
            color: config.color.colorFor(colorScheme, .base).color.uiColor()
        )
        markdownParser.bold.font = UIFont.boldSystemFont(
            ofSize: config.fontStyle.fontSize * config.fontStyle.multiplier
        )
        markdownParser.header.font = Fonts.fontFor(style: config.fontStyle)
        markdownParser.italic.font = UIFont.italicSystemFont(
            ofSize: config.fontStyle.fontSize * config.fontStyle.multiplier
        )
        let attributedString = markdownParser.parse(text)

        if !text.isEmpty {
            let mutableAttributedString = NSMutableAttributedString(
                attributedString: attributedString
            )
            attributedText = mutableAttributedString
            textAlignment = config.textAlignment
        }
    }

    func calculateHeight() {
        let newSize = getSize()
        frame.size = newSize
        DispatchQueue.main.async { [weak self] in
            self?.height = newSize.height
            self?.width = newSize.width
        }
    }

    private func getSize() -> CGSize {
        let newSize = sizeThatFits(
            CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        )
        return newSize
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange) -> Bool {
        let emailMasking = Masking(type: .email)
        if emailMasking.isValid(text: URL.absoluteString) {
            let emailURL = "mailto:" + URL.absoluteString
            if let url = Foundation.URL(string: emailURL) {
                Dependencies.urlOpener.open(url)
            }
        } else {
            config.onUrlClicked(URL)
        }

        return false
    }

    override func becomeFirstResponder() -> Bool {
        false
    }

    override var canBecomeFirstResponder: Bool {
        false
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
