import Foundation
import SwiftUI
import hCore

public struct hTextView: View {
    private let placeholder: String
    private let popupPlaceholder: String
    private let minCharacters: Int
    private let maxCharacters: Int
    @State private var height: CGFloat = 100
    @State private var width: CGFloat = 0
    @Environment(\.hTextFieldError) var errorMessage
    @State private var value: String = ""
    @State private var selectedValue: String = ""
    @State private var popoverHeight: CGFloat = 0
    private let onContinue: (_ text: String) -> Void
    private let enabled: Bool
    private let color: UIColor
    public init(
        selectedValue: String,
        placeholder: String,
        popupPlaceholder: String,
        minCharacters: Int? = 0,
        maxCharacters: Int,
        enabled: Bool = true,
        color: UIColor = UIColor { trait in
            let style = trait.userInterfaceStyle
            return hSurfaceColor.Opaque.primary.colorFor(style == .dark ? .dark : .light, .base).color.uiColor()
        },
        onContinue: @escaping (_ text: String) -> Void = { _ in }
    ) {
        self.selectedValue = selectedValue
        self.placeholder = placeholder
        self.popupPlaceholder = popupPlaceholder
        self.onContinue = onContinue
        self.minCharacters = minCharacters ?? 0
        self.maxCharacters = maxCharacters
        self.enabled = enabled
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                hSection {
                    VStack(alignment: .trailing, spacing: 4) {
                        SwiftUITextView(
                            placeholder: placeholder,
                            text: $selectedValue,
                            becomeFirstResponder: false,
                            disabled: true,
                            height: $height,
                            width: $width,
                            inEdit: .constant(false),
                            onBeginEditing: {
                                if enabled {
                                    showFreeTextField()
                                }
                            },
                            color: enabled ? color : nil
                        )
                        .padding(.leading, -4)
                        .frame(height: height)
                        .padding(.bottom, enabled ? 0 : .padding12)
                        if enabled {
                            HStack(spacing: .padding4) {
                                Spacer()
                                hText("\(selectedValue.count)/\(maxCharacters)", style: .label)
                                    .foregroundColor(hTextColor.Opaque.tertiary)
                            }
                            .fixedSize()
                            .padding(.bottom, .padding12)
                        }
                    }
                }
                .padding(.top, .padding12)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                if errorMessage != nil {
                    hCoreUIAssets.warningTriangleFilled.view
                        .foregroundColor(hSignalColor.Amber.element)
                        .frame(width: 24, height: 24)
                        .padding(.top, .padding12)
                        .padding(.trailing, .padding16)
                }
            }
            .background {
                Color(uiColor: color)
            }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
            .sectionContainerStyle(.transparent)
            if let errorMessage {
                hText(errorMessage, style: .label).foregroundColor(hTextColor.Translucent.secondary)
                    .padding(.horizontal, .padding16)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(placeholder)
        .accessibilityAddTraits(.isButton)
    }

    private func showFreeTextField() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}

        value = selectedValue
        let textViewHeigth = TextView.getHeight(forText: selectedValue, placeholder: placeholder, and: width)
        popoverHeight = textViewHeigth + 12
        let view = FreeTextInputView(
            continueAction: continueAction,
            cancelAction: cancelAction,
            value: $value,
            title: placeholder,
            placeholder: popupPlaceholder,
            minCharacters: minCharacters,
            maxCharacters: maxCharacters,
            height: $popoverHeight,
            color: color
        )
        .hTextFieldError(errorMessage)

        let vc = hHostingController(rootView: view, contentName: "EnterCommentTextView")
        vc.modalPresentationStyle = .overFullScreen
        vc.view.backgroundColor = .clear
        continueAction.execute = { [weak vc] in
            selectedValue = value
            onContinue(value)
            UIView.animate(withDuration: 0.1) {
                vc?.view.backgroundColor = .clear
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                vc?.dismiss(animated: true)
            }
        }
        Task { [weak vc] in
            let color = UIColor(
                light: hGrayscaleOpaqueColor.white.colorFor(.light, .base).color.uiColor(),
                dark: hGrayscaleOpaqueColor.black.colorFor(.dark, .base).color.uiColor()
            )
            try await Task.sleep(seconds: 0.3)
            UIView.animate(withDuration: 0.2) {
                vc?.view.backgroundColor = color
            }
        }
        cancelAction.execute = { [weak vc] in
            UIView.animate(withDuration: 0.1) {
                vc?.view.backgroundColor = .clear
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                vc?.dismiss(animated: true)
            }
        }
        let topVC = UIApplication.shared.getTopViewController()
        if let topVC {
            topVC.present(vc, animated: true)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var valuee = ""
        @State var error: String? = nil

        var body: some View {
            VStack(spacing: 4) {
                VStack {
                    hForm {}
                        .hFormTitle(title: .init(.standard, .heading2, "TITLE"))
                        .hFormAttachToBottom {
                            VStack(spacing: 20) {
                                hSection {
                                    hTextView(
                                        selectedValue: valuee,
                                        placeholder: "Placeholder LONG ONE PLACE H O L D E R THAT NEEDS more rows",
                                        popupPlaceholder: "title",
                                        minCharacters: 5,
                                        maxCharacters: 2000,
                                        enabled: true
                                    ) { value in
                                        valuee = value
                                    }
                                    .hTextFieldError(error)
                                }
                                .sectionContainerStyle(.transparent)
                            }
                        }
                }
            }
        }
    }
    return PreviewWrapper()
}

private struct FreeTextInputView: View {
    fileprivate let title: String
    fileprivate let placeholder: String
    fileprivate let minCharacters: Int
    fileprivate let maxCharacters: Int
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    @Binding fileprivate var value: String
    @State var height: CGFloat = 0
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State private var inEdit: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    private let color: UIColor
    public init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        value: Binding<String>,
        title: String,
        placeholder: String,
        minCharacters: Int,
        maxCharacters: Int,
        height: Binding<CGFloat>,
        color: UIColor
    ) {
        self.title = title
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        _value = value
        self.placeholder = placeholder
        self.minCharacters = minCharacters
        self.maxCharacters = maxCharacters
        self.color = color
    }

    public var body: some View {
        VStack(spacing: 0) {
            hSection {
                VStack(spacing: 0) {
                    hSection {
                        HStack {
                            hText(title, style: .body1)
                            Spacer()
                            Button(
                                action: {
                                    cancelAction.execute()
                                },
                                label: {
                                    hCoreUIAssets.close.view
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(.vertical, .padding12)
                                        .foregroundColor(hFillColor.Opaque.primary)
                                }
                            )
                        }
                    }
                    .padding(.bottom, -.padding8)
                    .sectionContainerStyle(.transparent)
                    hSection {
                        SwiftUITextView(
                            placeholder: placeholder,
                            text: $value,
                            becomeFirstResponder: true,
                            disabled: false,
                            height: $height,
                            width: .constant(0),
                            inEdit: $inEdit,
                            color: color
                        )
                        .padding(.leading, -4)
                        .frame(maxHeight: max(height, 100))
                    }
                    .sectionContainerStyle(.transparent)
                    Spacer()
                    hSection {
                        HStack {
                            Spacer()
                            HStack(spacing: .padding4) {
                                Spacer()
                                hText("\(value.count)/\(maxCharacters)", style: .label)
                                    .foregroundColor(hTextColor.Opaque.tertiary)
                            }
                        }
                        .padding(.bottom, .padding8)
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
            .sectionContainerStyle(.opaque)
            .colorScheme(colorScheme)
            hSection {
                HStack(spacing: .padding8) {
                    hButton(
                        .medium,
                        .secondary,
                        content: .init(title: L10n.generalCancelButton)
                    ) {
                        cancelAction.execute()
                    }
                    hButton(
                        .medium,
                        .primary,
                        content: .init(title: L10n.generalSaveButton),
                        {
                            continueAction.execute()
                        }
                    )
                }
                .padding(.vertical, .padding8)
                .hButtonTakeFullWidth(true)
            }
            .layoutPriority(1)
            .sectionContainerStyle(.transparent)
        }
    }
}

private struct SwiftUITextView: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    let becomeFirstResponder: Bool
    let disabled: Bool
    @Binding var height: CGFloat
    @Binding var width: CGFloat
    @Binding var inEdit: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.hTextFieldError) var errorMessage
    var onBeginEditing: (() -> Void)?
    let color: UIColor?
    func makeUIView(context _: Context) -> UITextView {
        let textView = TextView(
            placeholder: placeholder,
            inputText: $text,
            height: $height,
            width: $width,
            becomeFirstResponder: becomeFirstResponder,
            disabled: disabled,
            inEdit: $inEdit,
            onBeginEditing: onBeginEditing
        )
        textView.setText(text: text)
        textView.colorSchema = colorScheme
        textView.updateHeight()

        return textView
    }

    func updateUIView(_ uiView: UITextView, context _: Context) {
        if let textView = uiView as? TextView {
            if disabled {
                textView.setText(text: text)
                textView.updateHeight()
            }
            textView.colorSchema = colorScheme
            textView.errorMessage = errorMessage
        }
        uiView.backgroundColor = color
    }
}

private class TextView: UITextView, UITextViewDelegate {
    private let disabled: Bool
    @Binding private var inputText: String
    @Binding private var height: CGFloat
    @Binding private var width: CGFloat
    @Binding private var inEdit: Bool
    private let placeholderView = UITextView()
    var onBeginEditing: (() -> Void)?

    var errorMessage: String? {
        didSet {
            layoutSubviews()
        }
    }

    var colorSchema: ColorScheme = .light {
        didSet {
            textColor = getTextColor()
            placeholderView.textColor = getPlaceholderColor()
        }
    }

    init(
        placeholder: String,
        inputText: Binding<String>,
        height: Binding<CGFloat>,
        width: Binding<CGFloat>,
        becomeFirstResponder: Bool,
        disabled: Bool,
        inEdit: Binding<Bool>,
        onBeginEditing: (() -> Void)? = nil
    ) {
        _inputText = inputText
        self.disabled = disabled
        _height = height
        _width = width
        _inEdit = inEdit
        self.onBeginEditing = onBeginEditing
        super.init(frame: .zero, textContainer: nil)
        textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        delegate = self
        font = Fonts.fontFor(style: .body1)
        backgroundColor = .clear
        layer.cornerRadius = 12
        setText(text: inputText.wrappedValue)
        textContainer.lineBreakMode = .byTruncatingTail
        keyboardAppearance = .dark
        addSubview(placeholderView)
        placeholderView.textColor = getPlaceholderColor()
        placeholderView.delegate = self
        placeholderView.backgroundColor = .clear
        placeholderView.textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        placeholderView.text = placeholder
        placeholderView.font = Fonts.fontFor(style: .body1)
        placeholderView.isHidden = inputText.wrappedValue != ""
        placeholderView.delegate = self
        if becomeFirstResponder {
            self.becomeFirstResponder()
        } else {
            isEditable = false
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            addGestureRecognizer(gesture)
        }

        updateHeight()
        Task { [weak self] in
            // Delay to ensure the view is fully laid out before updating height
            try await Task.sleep(seconds: 0.3)
            self?.updateHeight()
        }
    }

    @objc private func handleTapGesture() {
        onBeginEditing?()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if disabled {
            Task { @MainActor [weak self] in
                self?.onBeginEditing?()
            }
            return false
        } else if textView == placeholderView {
            becomeFirstResponder()
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_: UITextView) {
        inEdit = true
    }

    func textViewDidChange(_ textView: UITextView) {
        inputText = textView.text
        textColor = getTextColor()
        updateHeight()
    }

    func setText(text: String) {
        self.text = text
        textColor = getTextColor()
        placeholderView.isHidden = text != ""
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        inEdit = false
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = text
    }

    func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText _: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.updateHeight()
            self?.placeholderView.isHidden = self?.text != ""
        }
        return true
    }

    private func getTextColor() -> UIColor {
        if disabled {
            return hTextColor.Translucent.secondary.colorFor(.init(.init(colorSchema))!, .base).color.uiColor()
        }
        return hTextColor.Opaque.primary.colorFor(.init(.init(colorSchema))!, .base).color.uiColor()
    }

    private func getPlaceholderColor() -> UIColor {
        hTextColor.Opaque.tertiary.colorFor(.init(.init(colorSchema))!, .base).color.uiColor()
    }

    func updateHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            withAnimation {
                if self.frame.width > 0 {
                    let contentSize = self.sizeThatFits(.init(width: self.frame.width, height: .infinity)).height
                    let labelHeight = self.placeholderView
                        .sizeThatFits(.init(width: self.frame.width, height: .infinity)).height
                    let height = max(contentSize, labelHeight)
                    if disabled {
                        self.height = 100
                    } else {
                        self.height = max(height + 12, 100)
                    }
                    self.width = self.frame.width
                }
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let frameWidth = frame.width
        let labelSize = placeholderView.sizeThatFits(.init(width: frame.width, height: .infinity))
        placeholderView.frame = .init(x: 0, y: 0, width: frameWidth, height: labelSize.height)
        if disabled {
            let transparent = UIColor(white: 0, alpha: 0).cgColor
            let opaque = UIColor(white: 0, alpha: 1).cgColor

            let maskLayer = CALayer()
            maskLayer.frame = bounds

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(
                x: bounds.origin.x,
                y: 0,
                width: bounds.size.width,
                height: bounds.size.height
            )
            gradientLayer.colors = [transparent, opaque, opaque, transparent]
            gradientLayer.locations = [0.0, 0.02, 0.98, 1.0]

            maskLayer.addSublayer(gradientLayer)
            layer.mask = maskLayer
        }
    }
}

@MainActor
private struct SafeAreaInsetsKey: @preconcurrency EnvironmentKey {
    static var defaultValue: EdgeInsets {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .windows
            .filter(\.isKeyWindow).first
        return (keyWindow?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

extension UIEdgeInsets {
    fileprivate var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension TextView {
    fileprivate static func getHeight(forText text: String, placeholder: String, and width: CGFloat) -> CGFloat {
        let textView = TextView(
            placeholder: placeholder,
            inputText: .constant(text),
            height: .constant(0),
            width: .constant(0),
            becomeFirstResponder: false,
            disabled: false,
            inEdit: .constant(false)
        )
        let textViewHeight = textView.sizeThatFits(.init(width: width, height: .infinity)).height
        let labelHeight = textView.placeholderView.sizeThatFits(.init(width: width, height: .infinity)).height
        return max(textViewHeight, labelHeight)
    }
}
