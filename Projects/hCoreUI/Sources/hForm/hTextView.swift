import Foundation
import Hero
import SwiftUI
import hCore

public struct hTextView: View {
    private let placeholder: String
    private let popupPlaceholder: String
    private let required: Bool
    private let maxCharacters: Int
    @State private var height: CGFloat = 100
    @State private var width: CGFloat = 0
    @Environment(\.hTextFieldError) var errorMessage
    @State private var value: String = ""
    @State private var selectedValue: String = ""
    @State private var popoverHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorSchema
    private let onContinue: (_ text: String) -> Void
    private let enableTransition: Bool
    public init(
        selectedValue: String,
        placeholder: String,
        popupPlaceholder: String,
        required: Bool,
        maxCharacters: Int,
        enableTransition: Bool,
        onContinue: @escaping (_ text: String) -> Void = { _ in }
    ) {
        self.selectedValue = selectedValue
        self.placeholder = placeholder
        self.popupPlaceholder = popupPlaceholder
        self.onContinue = onContinue
        self.required = required
        self.enableTransition = enableTransition
        self.maxCharacters = maxCharacters
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
                            enableTransition: enableTransition,
                            onBeginEditing: {
                                showFreeTextField()
                            }
                        )
                        .padding(.leading, -4)
                        .frame(height: height)
                        HeroAnimationWrapper(id: "counter", cornerRadius: 0, enableTransition: enableTransition) {
                            HStack(spacing: .padding4) {
                                Spacer()
                                hText("\(value.count)/\(maxCharacters)", style: .label)
                                    .foregroundColor(hTextColor.Opaque.tertiary)
                            }
                            .fixedSize()
                        }
                        .fixedSize()
                        .id(UUID().uuidString)
                        .padding(.bottom, .padding12)
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
                hSurfaceColor.Opaque.primary
            }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
            if let errorMessage {
                hText(errorMessage, style: .label).foregroundColor(hTextColor.Translucent.secondary)
                    .padding(.horizontal, .padding16)
            }

        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(placeholder)
        .accessibilityAddTraits(.isButton)
    }

    @hColorBuilder
    var getTextColor: some hColor {
        if selectedValue.count < maxCharacters {
            hTextColor.Opaque.tertiary
        } else {
            hSignalColor.Red.element
        }
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
            maxCharacters: maxCharacters,
            height: $popoverHeight,
            enableTransition: enableTransition
        )
        .hTextFieldError(errorMessage)

        let vc = hHostingController(rootView: view, contentName: "EnterCommentTextView")
        vc.modalPresentationStyle = .overFullScreen
        if enableTransition {
            vc.enableHero()
        }
        vc.view.backgroundColor = hGrayscaleOpaqueColor.black.colorFor(.dark, .base).color.uiColor()

        continueAction.execute = { [weak vc] in
            self.selectedValue = value
            self.value = value
            self.onContinue(value)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                vc?.dismiss(animated: true)
            }
        }
        cancelAction.execute = { [weak vc] in
            vc?.dismiss(animated: true)
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
                                        required: true,
                                        maxCharacters: 2000,
                                        enableTransition: false
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

private struct FreeTextInputView: View, KeyboardReadableHeight {
    fileprivate let title: String
    fileprivate let placeholder: String
    fileprivate let maxCharacters: Int
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    fileprivate let enableTransition: Bool
    @Binding fileprivate var value: String
    @Binding private var height: CGFloat
    @State var showButtons = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State var keyboard: CGFloat = 303.99
    @State private var inEdit: Bool = false
    let initDate = Date()
    @Environment(\.hTextFieldError) var errorMessage
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass

    public init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        value: Binding<String>,
        title: String,
        placeholder: String,
        maxCharacters: Int,
        height: Binding<CGFloat>,
        enableTransition: Bool
    ) {
        self.title = title
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self._value = value
        self.placeholder = placeholder
        self.maxCharacters = maxCharacters
        self.enableTransition = enableTransition
        self._height = height
    }

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                hSection {
                    VStack(spacing: 8) {
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
                                            .padding(12)
                                            .foregroundColor(hFillColor.Opaque.primary)
                                    }
                                )
                            }
                        }
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
                                enableTransition: enableTransition
                            )
                            .padding(.leading, -4)
                            .frame(maxHeight: max(height, 100))
                            .frame(minHeight: 100)
                        }
                        .sectionContainerStyle(.transparent)
                        Spacer()
                        hSection {
                            HStack {
                                Spacer()
                                HeroAnimationWrapper(id: "counter", cornerRadius: 0, enableTransition: enableTransition)
                                {
                                    HStack(spacing: .padding4) {
                                        Spacer()
                                        if value.count > maxCharacters {
                                            hCoreUIAssets.warningTriangleFilled.view
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(hSignalColor.Amber.element)
                                        }
                                        hText("\(value.count)/\(maxCharacters)", style: .label)
                                            .foregroundColor(getTextColor)
                                    }
                                }
                                .id(UUID().uuidString)
                                .fixedSize()
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    .padding(.vertical, .padding16)
                }
                .sectionContainerStyle(.opaque)
                .colorScheme(colorScheme)
                hSection {
                    HStack(spacing: .padding8) {
                        hCancelButton {
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
                        .disabled(value.count > maxCharacters)
                    }
                    .padding(.bottom, .padding8)
                    .hButtonTakeFullWidth(true)
                }
                .sectionContainerStyle(.transparent)
            }
            .frame(
                maxHeight: verticalSizeClass == .compact
                    ? nil : UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - keyboard
            )
        }
        .colorScheme(.dark)
        .ignoresSafeArea(verticalSizeClass == .compact ? [] : .keyboard, edges: .bottom)
        .onReceive(keyboardHeightPublisher) { newHeight in
            if let newHeight {
                keyboard = newHeight - 44 + 12
            }
        }
        .onChange(of: inEdit) { inEdit in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if keyboard == 303.99 {
                    withAnimation {
                        keyboard = 0
                    }
                }
            }
        }
    }

    @hColorBuilder
    var getTextColor: some hColor {
        if value.count < maxCharacters {
            hTextColor.Opaque.tertiary
        } else {
            hSignalColor.Red.element
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
    let enableTransition: Bool
    var onBeginEditing: (() -> Void)? = nil
    internal func makeUIView(context: Context) -> UITextView {
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
        textView.hero.isEnabled = enableTransition
        textView.hero.id = "textViewHeroId"
        textView.heroModifiers = [.spring(stiffness: 450, damping: 35)]

        return textView
    }

    internal func updateUIView(_ uiView: UITextView, context: Context) {
        if let textView = uiView as? TextView {
            if disabled {
                textView.setText(text: text)
                textView.updateHeight()
            }
            textView.colorSchema = colorScheme
            textView.errorMessage = errorMessage
        }
        uiView.backgroundColor = hSurfaceColor.Opaque.primary.colorFor(.init(.init(colorScheme))!, .base).color
            .uiColor()

    }

}

private class TextView: UITextView, UITextViewDelegate {
    private let disabled: Bool
    @Binding private var inputText: String
    @Binding private var height: CGFloat
    @Binding private var width: CGFloat
    @Binding private var inEdit: Bool
    private let placeholderView = UITextView()
    var onBeginEditing: (() -> Void)? = nil

    var errorMessage: String? {
        didSet {
            layoutSubviews()
        }
    }
    var colorSchema: ColorScheme = .light {
        didSet {
            self.textColor = getTextColor()
            self.placeholderView.textColor = getPlaceholderColor()
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
        self._inputText = inputText
        self.disabled = disabled
        self._height = height
        self._width = width
        self._inEdit = inEdit
        self.onBeginEditing = onBeginEditing
        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        self.delegate = self
        self.font = Fonts.fontFor(style: .body1)
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.setText(text: inputText.wrappedValue)
        self.textContainer.lineBreakMode = .byTruncatingTail
        self.keyboardAppearance = .dark
        self.addSubview(placeholderView)
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
            self.addGestureRecognizer(gesture)
        }

        updateHeight()
        Task { [weak self] in
            // Delay to ensure the view is fully laid out before updating height
            try await Task.sleep(nanoseconds: 300_000_000)
            self?.updateHeight()
        }
    }

    @objc private func handleTapGesture() {
        self.onBeginEditing?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if disabled {
            Task { @MainActor [weak self] in
                self?.onBeginEditing?()
            }
            return false
        } else if textView == placeholderView {
            self.becomeFirstResponder()
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        inEdit = true
    }

    func textViewDidChange(_ textView: UITextView) {
        inputText = textView.text
        self.textColor = getTextColor()
        updateHeight()
    }

    func setText(text: String) {
        self.text = text
        self.textColor = getTextColor()
        self.placeholderView.isHidden = text != ""
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        inEdit = false
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = text
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
        return hTextColor.Opaque.tertiary.colorFor(.init(.init(colorSchema))!, .base).color.uiColor()
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
        let frameWidth = self.frame.width
        let labelSize = self.placeholderView.sizeThatFits(.init(width: self.frame.width, height: .infinity))
        self.placeholderView.frame = .init(x: 0, y: 0, width: frameWidth, height: labelSize.height)
        if disabled {
            let transparent = UIColor(white: 0, alpha: 0).cgColor
            let opaque = UIColor(white: 0, alpha: 1).cgColor

            let maskLayer = CALayer()
            maskLayer.frame = self.bounds

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(
                x: self.bounds.origin.x,
                y: 0,
                width: self.bounds.size.width,
                height: self.bounds.size.height
            )
            gradientLayer.colors = [transparent, opaque, opaque, transparent]
            gradientLayer.locations = [0.0, 0.02, 0.98, 1.0]

            maskLayer.addSublayer(gradientLayer)
            self.layer.mask = maskLayer
        }
    }
}

@MainActor
private struct SafeAreaInsetsKey: @preconcurrency EnvironmentKey {
    static var defaultValue: EdgeInsets {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?
            .windows
            .filter({ $0.isKeyWindow }).first
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
