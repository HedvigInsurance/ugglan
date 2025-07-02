import Foundation
import MarkdownKit
import SnapKit
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
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
            .frame(height: height)
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

    func makeUIView(context: Context) -> CustomTextView {
        let textView = CustomTextView(
            config: config,
            fixedWidth: fixedWidth,
            height: $height,
            width: $width,
            colorScheme: colorScheme
        )
        textView.accessibilityLabel = accessibilityLabel
        return textView
    }
    func updateUIView(_ uiView: CustomTextView, context: Context) {
        uiView.setContent(from: config.text)
        uiView.calculateHeight()
        uiView.accessibilityLabel = accessibilityLabel
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
        self.environment(\.hEnvironmentAccessibilityLabel, label)
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
        setContent(from: config.text)
        calculateHeight()
        self.clipsToBounds = false
        self.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(fixedWidth)
        }
    }

    private func configureTextView() {
        self.backgroundColor = .clear
        self.isEditable = false
        self.isUserInteractionEnabled = true
        self.isScrollEnabled = false
        self.isSelectable = true
        self.backgroundColor = .clear
        self.dataDetectorTypes = [.address, .link, .phoneNumber]
        self.clipsToBounds = false
        accessibilityTraits = .staticText
        var linkTextAttributes = [NSAttributedString.Key: Any]()
        linkTextAttributes[.foregroundColor] = config.linkColor.colorFor(colorScheme, .base).color.uiColor()
        linkTextAttributes[.underlineColor] = config.linkColor.colorFor(colorScheme, .base).color.uiColor()
        if let linkUnderlineStyle = config.linkUnderlineStyle {
            linkTextAttributes[.underlineStyle] = linkUnderlineStyle.rawValue
        }
        self.linkTextAttributes = linkTextAttributes
        self.textContainerInset = .zero
        self.delegate = self
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
            self.attributedText = mutableAttributedString
            self.textAlignment = config.textAlignment
        }
    }

    func calculateHeight() {
        let newSize = getSize()
        self.frame.size = newSize
        DispatchQueue.main.async { [weak self] in
            self?.height = newSize.height
            self?.width = newSize.width - 12
        }
    }

    private func getSize() -> CGSize {
        let newSize = self.sizeThatFits(
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
