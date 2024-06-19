import Flow
import Foundation
import Hero
import Presentation
import SwiftUI
import hCore

public struct hTextView: View {
    private let placeholder: String
    private let required: Bool
    private let maxCharacters: Int
    @State private var height: CGFloat = 50
    @State private var width: CGFloat = 0
    @Environment(\.hTextFieldError) var errorMessage
    @State private var value: String = ""
    @State private var disposeBag = DisposeBag()
    @State private var selectedValue: String = ""
    @State private var popoverHeight: CGFloat = 0
    @State private var numberOfLines: Int = 0
    @State private var popoverNumberOfLines: Int = 0

    private let onContinue: (_ text: String) -> Void
    public init(
        selectedValue: String,
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
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                HeroAnimationWrapper {}
                hSection {
                    VStack(spacing: 4) {
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
                    }
                }
                .hSectionMinimumPadding
                .padding(.top, .padding12)
                .sectionContainerStyle(.transparent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(minHeight: 100)
                if errorMessage != nil {
                    hCoreUIAssets.warningTriangleFilled.view
                        .foregroundColor(hSignalColor.Amber.element)
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
                hText(errorMessage, style: .standardSmall).foregroundColor(hTextColor.Opaque.secondary)
                    .padding(.horizontal, .padding16)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
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
        let textViewHeigth = TextView.getHeight(forText: selectedValue, and: width)
        popoverHeight = textViewHeigth + 12
        let view = FreeTextInputView(
            continueAction: continueAction,
            cancelAction: cancelAction,
            value: $value,
            placeholder: placeholder,
            maxCharacters: maxCharacters,
            height: $popoverHeight,
            numberOfLines: $popoverNumberOfLines
        )
        .colorScheme(.dark)

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

#Preview{
    @State var valuee = ""
    return VStack(spacing: 4) {
        VStack {
            hForm {}
                .hFormTitle(title: .init(.standard, .heading2, "TITLE"))
                .hFormMergeBottomViewWithContentIfNeeded
                .hFormAttachToBottom {
                    VStack(spacing: 20) {
                        Rectangle().frame(height: 20)
                        hSection {
                            hTextView(
                                selectedValue: valuee,
                                placeholder: "placeholder",
                                required: true,
                                maxCharacters: 2000
                            ) { value in
                                valuee = value
                            }
                        }
                        hSection {
                            hTextView(
                                selectedValue: valuee,
                                placeholder: "placeholder",
                                required: true,
                                maxCharacters: 140
                            ) { value in
                                valuee = value
                            }
                        }
                        hSection {
                            hTextView(
                                selectedValue: valuee,
                                placeholder: "placeholder",
                                required: true,
                                maxCharacters: 140
                            ) { value in
                                valuee = value
                            }
                        }
                        hSection {
                            hTextView(
                                selectedValue: valuee,
                                placeholder: "placeholder",
                                required: true,
                                maxCharacters: 140
                            ) { value in
                                valuee = value
                            }
                        }
                        hSection {
                            hTextView(
                                selectedValue: valuee,
                                placeholder: "placeholder",
                                required: true,
                                maxCharacters: 140
                            ) { value in
                                valuee = value
                            }
                        }
                        hSection {
                            hTextView(
                                selectedValue: valuee,
                                placeholder: "placeholder",
                                required: true,
                                maxCharacters: 140
                            ) { value in
                                valuee = value
                            }
                        }
                        Rectangle().frame(height: 20)
                    }

                }
        }
    }
}

private struct FreeTextInputView: View, KeyboardReadableHeight {
    fileprivate let placeholder: String
    fileprivate let maxCharacters: Int
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    @Binding fileprivate var value: String
    @Binding private var height: CGFloat
    @State var showButtons = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State var keyboard: CGFloat = 303.99
    @Binding var numberOfLines: Int
    @State private var inEdit: Bool = false
    let initDate = Date()
    @State var showCounter = true
    public init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        value: Binding<String>,
        placeholder: String,
        maxCharacters: Int,
        height: Binding<CGFloat>,
        numberOfLines: Binding<Int>
    ) {
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self._value = value
        self.placeholder = placeholder
        self.maxCharacters = maxCharacters
        self._height = height
        self._numberOfLines = numberOfLines
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear.ignoresSafeArea()
            VStack(spacing: 8) {
                ZStack {
                    HeroAnimationWrapper {
                        hSection {
                            VStack {
                                Spacer()
                                if showCounter {
                                    hText("\(value.count)/\(maxCharacters)", style: .standardSmall)
                                        .foregroundColor(getTextColor)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                            .padding(.vertical, .padding12)
                        }
                        .colorScheme(.light)
                    }
                    .id(UUID().uuidString)
                    .colorScheme(.light)
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
                            hText("\(value.count)/\(maxCharacters)", style: .standardSmall)
                                .foregroundColor(getTextColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                        }
                        .padding(.vertical, .padding12)
                    }
                    .colorScheme(.light)
                    .sectionContainerStyle(.transparent)

                }
                .padding(.horizontal, .padding16)
                VStack(spacing: 0) {
                    hSection {
                        HStack(spacing: 8) {
                            hButton.MediumButton(type: .secondary) {
                                cancelAction.execute()
                            } content: {
                                hText(L10n.generalCancelButton)
                            }
                            hButton.MediumButton(type: .primary) {
                                continueAction.execute()
                            } content: {
                                hText(L10n.generalSaveButton)
                            }
                            .disabled(value.count > maxCharacters)
                        }
                        .padding(.bottom, .padding8)
                    }
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showCounter = false
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
        }
        uiView.backgroundColor = hSurfaceColor.Opaque.primary.colorFor(.init(.init(colorScheme))!, .base).color
            .uiColor()

    }
}

private class TextView: UITextView, UITextViewDelegate {
    private let placeholder: String
    private let disabled: Bool
    @Binding private var inputText: String
    @Binding private var height: CGFloat
    @Binding private var width: CGFloat
    @Binding private var numberOfLines: Int
    @Binding private var inEdit: Bool
    var colorSchema: ColorScheme = .light {
        didSet {
            self.textColor = getTextColor()

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
        self.placeholder = placeholder
        self._inputText = inputText
        self.disabled = disabled
        self._height = height
        self._numberOfLines = numberOfLines
        self._width = width
        self._inEdit = inEdit

        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(horizontalInset: 0, verticalInset: 0)
        self.delegate = self
        self.font = Fonts.fontFor(style: .body1)
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.setText(text: inputText.wrappedValue)
        self.isUserInteractionEnabled = !disabled
        self.textContainer.maximumNumberOfLines = disabled ? 3 : 0
        self.textContainer.lineBreakMode = .byTruncatingTail
        self.keyboardAppearance = .dark
        if becomeFirstResponder {
            self.becomeFirstResponder()
        }

        updateHeight()
    }

    @objc private func handleDoneButtonTap() {
        self.resignFirstResponder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        inEdit = true
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text == placeholder {
            textView.text = nil
            textView.textColor = getTextColor()
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        inputText = textView.text
        self.textColor = getTextColor()
        updateHeight()
    }

    func setText(text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            self.text = placeholder
        } else {
            self.text = text
        }
        self.textColor = getTextColor()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        inEdit = false
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = text
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = getTextColor()
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            return false
        }

        return true
    }

    private func getTextColor() -> UIColor {
        if text.isEmpty || placeholder == text {
            return hTextColor.Opaque.tertiary.colorFor(.init(.init(colorSchema))!, .base).color.uiColor()
        } else {
            if disabled {
                return hTextColor.Translucent.secondary.colorFor(.init(.init(colorSchema))!, .base).color.uiColor()
            }
            return hTextColor.Opaque.primary.colorFor(.init(.init(colorSchema))!, .base).color.uiColor()
        }
    }

    func updateHeight() {
        DispatchQueue.main.async { [weak self] in guard let self = self else { return }
            withAnimation {
                let newSize = self.sizeThatFits(.init(width: self.frame.width, height: .infinity))
                if self.frame.width > 0 {
                    self.height = newSize.height + 12
                    self.numberOfLines = self.currentNumberOfLines()
                    self.width = self.frame.width
                }
            }
        }
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
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
    fileprivate static func getHeight(forText text: String, and width: CGFloat) -> CGFloat {
        let textView = TextView(
            placeholder: "",
            inputText: .constant(text),
            height: .constant(0),
            width: .constant(0),
            becomeFirstResponder: false,
            disabled: false,
            numberOfLines: .constant(0),
            inEdit: .constant(false)
        )
        return textView.sizeThatFits(.init(width: width, height: .infinity)).height
    }
}
