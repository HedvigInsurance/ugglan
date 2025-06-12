import Foundation
import Hero
import SwiftUI
import hCore

public struct hTextView: View {
    private let placeholder: String
    private let required: Bool
    private let titleText: String?
    private let maxCharacters: Int
    @State private var height: CGFloat = 50
    @State private var width: CGFloat = 0
    @Environment(\.hTextFieldError) var errorMessage
    @State private var value: String = ""
    @State private var selectedValue: String = ""
    @State private var popoverHeight: CGFloat = 0
    @State private var numberOfLines: Int = 0
    @State private var popoverNumberOfLines: Int = 0
    @Environment(\.colorScheme) var colorSchema
    private let onContinue: (_ text: String) -> Void
    public init(
        selectedValue: String,
        titleText: String? = nil,
        placeholder: String,
        required: Bool,
        maxCharacters: Int,
        onContinue: @escaping (_ text: String) -> Void = { _ in }
    ) {
        self.selectedValue = selectedValue
        self.placeholder = placeholder
        self.onContinue = onContinue
        self.required = required
        self.maxCharacters = maxCharacters
        self.titleText = titleText
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                HeroAnimationWrapper(id: "root") { Color.clear }

                hSection {
                    VStack(alignment: .trailing, spacing: 4) {
                        if let titleText {
                            HStack {
                                HeroAnimationWrapper(id: "label", cornerRadius: 0) {
                                    hText(titleText, style: .label)
                                        .foregroundColor(hTextColor.Translucent.secondary)
                                }
                                .fixedSize()
                                Spacer()
                            }
                        }
                        SwiftUITextView(
                            placeholder: placeholder,
                            text: $selectedValue,
                            becomeFirstResponder: false,
                            disabled: true,
                            height: $height,
                            width: $width,
                            numberOfLines: $numberOfLines,
                            inEdit: .constant(false)
                        )
                        .frame(height: max(height, 48))
                        Spacer()
                        HeroAnimationWrapper(id: "counter", cornerRadius: 0) {
                            HStack(spacing: .padding4) {
                                hText("\(value.count)/\(maxCharacters)", style: .label)
                                    .foregroundColor(hTextColor.Opaque.tertiary)
                            }
                        }
                        .padding(.bottom, .padding12)
                        .fixedSize()
                        .id(UUID().uuidString)
                    }
                }
                .padding(.top, .padding12)
                .sectionContainerStyle(.transparent)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                .frame(minHeight: 100)
                if errorMessage != nil {
                    hCoreUIAssets.warningTriangleFilled.view
                        .foregroundColor(hSignalColor.Amber.element)
                        .frame(width: 24, height: 24)

                        .padding(.top, .padding12)
                        .padding(.trailing, .padding16)
                }
                Rectangle()
                    .fill(Color.white.opacity(0.000001))
                    .onTapGesture {
                        showFreeTextField()
                    }
            }
            if let errorMessage {
                hText(errorMessage, style: .label).foregroundColor(hTextColor.Translucent.secondary)
                    .padding(.horizontal, .padding16)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
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
            placeholder: placeholder,
            maxCharacters: maxCharacters,
            height: $popoverHeight,
            numberOfLines: $popoverNumberOfLines,
            titleText: titleText
        )
        .hTextFieldError(errorMessage)
        .colorScheme(colorSchema)

        let vc = hHostingController(rootView: view, contentName: "EnterCommentTextView")
        vc.modalPresentationStyle = .overFullScreen
        vc.enableHero()
        vc.view.backgroundColor = hGrayscaleOpaqueColor.black.colorFor(.dark, .base).color.uiColor()

        continueAction.execute = { [weak vc] in
            self.selectedValue = value
            if numberOfLines != popoverNumberOfLines {
                let lineHeight = abs(Double(popoverHeight - height) / Double(popoverNumberOfLines - numberOfLines))
                let spacing = height - Double(numberOfLines) * lineHeight
                self.height = min(3 * lineHeight + spacing, popoverHeight)
            }
            self.value = value
            self.onContinue(value)
            vc?.dismiss(animated: true)
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
                                Rectangle().frame(height: 20)
                                hSection {
                                    hTextView(
                                        selectedValue: valuee,
                                        titleText: "TITLE LABEL",
                                        placeholder: "Placeholder LONG ONE PLACE H O L D E R THAT NEEDS more rows",
                                        required: true,
                                        maxCharacters: 2000
                                    ) { value in
                                        valuee = value
                                    }
                                    .hTextFieldError(error)
                                }
                                .sectionContainerStyle(.transparent)

                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            error = "ERROR"
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                        withAnimation {
                                            error = nil
                                        }
                                    }
                                }
                                Rectangle().frame(height: 20)
                            }

                        }
                }
            }
        }
    }
    return PreviewWrapper()
}

private struct FreeTextInputView: View, KeyboardReadableHeight {
    fileprivate let placeholder: String
    fileprivate let maxCharacters: Int
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    fileprivate let titleText: String?
    @Binding fileprivate var value: String
    @Binding private var height: CGFloat
    @State var showButtons = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State var keyboard: CGFloat = 303.99
    @Binding var numberOfLines: Int
    @State private var inEdit: Bool = false
    let initDate = Date()
    @Environment(\.hTextFieldError) var errorMessage
    @Environment(\.colorScheme) var colorScheme
    public init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        value: Binding<String>,
        placeholder: String,
        maxCharacters: Int,
        height: Binding<CGFloat>,
        numberOfLines: Binding<Int>,
        titleText: String?
    ) {
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self._value = value
        self.placeholder = placeholder
        self.maxCharacters = maxCharacters
        self._height = height
        self._numberOfLines = numberOfLines
        self.titleText = titleText
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear.ignoresSafeArea()
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    HeroAnimationWrapper(id: "root") { Color.clear }
                    hSection {
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Spacer()
                                HeroAnimationWrapper(id: "counter", cornerRadius: 0) {
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
                        .padding(.vertical, .padding12)
                    }
                    .sectionContainerStyle(.transparent)
                    hSection {
                        VStack {
                            SwiftUITextView(
                                placeholder: placeholder,
                                text: $value,
                                becomeFirstResponder: true,
                                disabled: false,
                                height: $height,
                                width: .constant(0),
                                numberOfLines: $numberOfLines,
                                inEdit: $inEdit
                            )
                            .frame(maxHeight: height)
                            Spacer()
                        }
                        .padding(.vertical, .padding12)
                    }
                    .sectionContainerStyle(.transparent)
                    if titleText != nil {
                        HeroAnimationWrapper(id: "label", cornerRadius: 12) {
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
                        .fixedSize()
                    } else {
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
                .padding(.horizontal, .padding16)
                VStack(spacing: 0) {
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
                    .colorScheme(.dark)
                    .sectionContainerStyle(.transparent)
                }
                .transition(.move(edge: .bottom))
            }
            .frame(height: UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - keyboard)
            .padding(.horizontal, -8)
        }
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
    @Binding var numberOfLines: Int
    @Binding var inEdit: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.hTextFieldError) var errorMessage
    internal func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let textView = TextView(
            placeholder: placeholder,
            inputText: $text,
            height: $height,
            width: $width,
            becomeFirstResponder: becomeFirstResponder,
            disabled: disabled,
            numberOfLines: $numberOfLines,
            inEdit: $inEdit
        )
        textView.setText(text: text)
        textView.colorSchema = colorScheme
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        textView.updateHeight()
        view.hero.id = "textViewHeroId"
        view.heroModifiers = [.spring(stiffness: 450, damping: 35)]

        return view
    }

    internal func updateUIView(_ uiView: UIView, context: Context) {
        if let textView = uiView.subviews.first as? TextView {
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
    @Binding private var numberOfLines: Int
    @Binding private var inEdit: Bool
    private let placeholderView = UITextView()
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
        numberOfLines: Binding<Int>,
        inEdit: Binding<Bool>
    ) {
        self._inputText = inputText
        self.disabled = disabled
        self._height = height
        self._numberOfLines = numberOfLines
        self._width = width
        self._inEdit = inEdit

        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        self.delegate = self
        self.font = Fonts.fontFor(style: .body1)
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.setText(text: inputText.wrappedValue)
        self.isUserInteractionEnabled = !disabled
        self.textContainer.maximumNumberOfLines = disabled ? 3 : 0
        self.textContainer.lineBreakMode = .byTruncatingTail
        self.keyboardAppearance = .dark
        self.addSubview(placeholderView)
        placeholderView.textColor = getPlaceholderColor()
        placeholderView.isUserInteractionEnabled = false
        placeholderView.backgroundColor = .clear
        placeholderView.textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        placeholderView.text = placeholder
        placeholderView.font = Fonts.fontFor(style: .body1)
        placeholderView.isHidden = inputText.wrappedValue != ""
        if becomeFirstResponder {
            self.becomeFirstResponder()
        }
        updateHeight()
        Task { [weak self] in
            // Delay to ensure the view is fully laid out before updating height
            try await Task.sleep(nanoseconds: 300_000_000)
            self?.updateHeight()
        }
    }

    @objc private func handleDoneButtonTap() {
        self.resignFirstResponder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            return false
        }
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
                    self.height = height + 12
                    self.numberOfLines = self.currentNumberOfLines()
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
        if inEdit || errorMessage != nil {
            let pathToExclude = UIBezierPath(rect: .init(x: frameWidth - 25, y: 0, width: 25, height: 25))
            self.textContainer.exclusionPaths = [pathToExclude]
            placeholderView.textContainer.exclusionPaths = [pathToExclude]
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

extension UITextView {

    func currentNumberOfLines() -> Int {
        if let fontUnwrapped = self.font {
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
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
            numberOfLines: .constant(0),
            inEdit: .constant(false)
        )
        let textViewHeight = textView.sizeThatFits(.init(width: width, height: .infinity)).height
        let labelHeight = textView.placeholderView.sizeThatFits(.init(width: width, height: .infinity)).height
        return max(textViewHeight, labelHeight)
    }
}
