import Foundation
import MarkdownKit
import SwiftUI
import hCore

public struct MarkdownView: View {
    private let config: CustomTextViewRepresentableConfig

    public init(
        config: CustomTextViewRepresentableConfig
    ) {
        self.config = config
    }

    public var body: some View {
        CustomTextViewRepresentable(config: config)
    }
}

struct CustomTextViewRepresentable: UIViewRepresentable {
    let config: CustomTextViewRepresentableConfig
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    @Environment(\.hEnvironmentAccessibilityLabel) var accessibilityLabel
    @Environment(\.sizeCategory) var sizeCategory

    init(config: CustomTextViewRepresentableConfig) {
        self.config = config
    }

    func makeUIView(context _: Context) -> CustomTextView {
        let textView = CustomTextView(config: config, colorScheme: colorScheme)
        textView.accessibilityLabel = accessibilityLabel
        textView.setContent(from: config.text)
        return textView
    }

    func updateUIView(_ textView: CustomTextView, context _: Context) {
        textView.colorScheme = colorScheme
        textView.setContent(from: config.text)
        if textView.accessibilityLabel != accessibilityLabel {
            textView.accessibilityLabel = accessibilityLabel
        }
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: CustomTextView,
        context _: Context
    ) -> CGSize? {
        // SwiftUI probes with `.zero`, `.unspecified`, and `.infinity` during layout discovery.
        // Reject zero/non-finite proposals so we never ask UITextView to wrap at width 0.
        let validProposal = proposal.width.flatMap { $0 > 0 && $0.isFinite ? $0 : nil }
        let width: CGFloat = {
            switch (validProposal, config.maxWidth) {
            case let (proposed?, max?): return min(proposed, max)
            case let (proposed?, nil): return proposed
            case let (nil, max?): return max
            case (nil, nil): return UIView.layoutFittingExpandedSize.width
            }
        }()
        return uiView.naturalSize(fittingWidth: width)
    }
}

extension EnvironmentValues {
    @Entry public var hEnvironmentAccessibilityLabel: String? = nil
}

extension View {
    public func hEnvironmentAccessibilityLabel(_ label: String?) -> some View {
        environment(\.hEnvironmentAccessibilityLabel, label)
    }
}

class CustomTextView: UITextView, UITextViewDelegate {
    let config: CustomTextViewRepresentableConfig
    private var lastAppliedText: String?
    private var lastAppliedColorScheme: ColorScheme?
    var colorScheme: ColorScheme {
        didSet {
            guard oldValue != colorScheme else { return }
            updateLinkTextAttributes()
        }
    }
    init(
        config: CustomTextViewRepresentableConfig,
        colorScheme: ColorScheme
    ) {
        self.config = config
        self.colorScheme = colorScheme
        super.init(frame: .zero, textContainer: nil)
        configureTextView()
    }

    func configureTextView() {
        backgroundColor = .clear
        isEditable = false
        isUserInteractionEnabled = true
        isScrollEnabled = false
        // Always enable isSelectable so links remain tappable
        // Text selection is controlled via selectedTextRange override
        isSelectable = true
        dataDetectorTypes = config.disableLinks ? [] : [.address, .link, .phoneNumber]
        accessibilityTraits = .staticText
        updateLinkTextAttributes()
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        if let maxLines = config.maxLines {
            textContainer.maximumNumberOfLines = maxLines
            textContainer.lineBreakMode = .byTruncatingTail
        }
        contentInset = .zero
        delegate = self
    }

    func updateLinkTextAttributes() {
        var linkTextAttributes = [NSAttributedString.Key: Any]()
        linkTextAttributes[.foregroundColor] = config.linkColor.colorFor(colorScheme, .base).color.uiColor()
        linkTextAttributes[.underlineColor] = config.linkColor.colorFor(colorScheme, .base).color.uiColor()
        if let linkUnderlineStyle = config.linkUnderlineStyle {
            linkTextAttributes[.underlineStyle] = linkUnderlineStyle.rawValue
        }
        self.linkTextAttributes = linkTextAttributes
    }

    /// Smallest size that fits the current attributed text within `fittingWidth`.
    func naturalSize(fittingWidth: CGFloat) -> CGSize {
        let constraint = CGSize(width: fittingWidth, height: .greatestFiniteMagnitude)
        if config.maxLines != nil {
            // Truncation is only respected by UITextView's own layout pass.
            return sizeThatFits(constraint)
        }
        guard let attributedText, attributedText.length > 0 else {
            return .zero
        }
        // `boundingRect` does one TextKit pass and gives both width and height. UITextView's
        // text container has zero inset and zero line padding, so its layout matches.
        let bounding = attributedText.boundingRect(
            with: constraint,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return CGSize(
            width: min(ceil(bounding.width), fittingWidth),
            height: ceil(bounding.height)
        )
    }

    func setContent(from text: String) {
        if lastAppliedText == text && lastAppliedColorScheme == colorScheme {
            return
        }
        lastAppliedText = text
        lastAppliedColorScheme = colorScheme

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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange) -> Bool {
        if config.disableLinks { return false }
        let emailMasking = Masking(type: .email)
        if emailMasking.isValid(text: URL.absoluteString) {
            let emailURL = "mailto:" + URL.absoluteString
            if let url = Foundation.URL(string: emailURL) {
                Dependencies.urlOpener.open(url)
            }
        } else {
            ImpactGenerator.light()
            config.onUrlClicked(URL)
        }

        return false
    }

    override var selectedTextRange: UITextRange? {
        get { config.isSelectable ? super.selectedTextRange : nil }
        set { if config.isSelectable { super.selectedTextRange = newValue } }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !config.isSelectable {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard super.point(inside: point, with: event) else { return false }

        if config.disableLinks {
            return config.isSelectable
        }

        if config.isSelectable {
            return true
        }

        // When not selectable, only respond to touches on links
        return urlAtPoint(point) != nil
    }

    private func urlAtPoint(_ point: CGPoint) -> URL? {
        let index = layoutManager.characterIndex(
            for: point,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        guard index < textStorage.length else { return nil }
        return attributedText.attribute(.link, at: index, effectiveRange: nil) as? URL
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
    let isSelectable: Bool
    let maxLines: Int?
    let disableLinks: Bool

    public init(
        text: Markdown,
        fontStyle: HFontTextStyle,
        color: any hColor,
        linkColor: any hColor,
        linkUnderlineStyle: NSUnderlineStyle?,
        maxWidth: CGFloat? = nil,
        textAlignment: NSTextAlignment = .left,
        isSelectable: Bool,
        maxLines: Int? = nil,
        disableLinks: Bool = false,
        onUrlClicked: @escaping (_: URL) -> Void
    ) {
        self.text = text
        self.fontStyle = fontStyle
        self.color = color
        self.linkColor = linkColor
        self.linkUnderlineStyle = linkUnderlineStyle
        self.textAlignment = textAlignment
        self.onUrlClicked = onUrlClicked
        self.isSelectable = isSelectable
        self.maxWidth = maxWidth
        self.maxLines = maxLines
        self.disableLinks = disableLinks
    }
}
