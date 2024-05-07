import Flow
import Foundation
import Hero
import Presentation
import SwiftUI
import hCore

public struct hTextView: View {
    private let placeholder: String
    private let selectedValue: String
    private let required: Bool
    private let maxCharacters: Int
    @State private var height: CGFloat = 50
    @Environment(\.hTextFieldError) var errorMessage
    @State private var value: String = ""
    @State private var disposeBag = DisposeBag()
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
                ZStack {
                    DummyView()
                    hSection {
                        VStack {
                            SwiftUITextView(
                                placeholder: placeholder,
                                text: .constant(selectedValue),
                                becomeFirstResponder: false,
                                disabled: true,
                                height: $height
                            )
                            .frame(height: height)
                            hText("\(value.count)/\(maxCharacters)", style: .standardSmall)
                                .foregroundColor(getTextColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 12)
                    }
                    .padding(.horizontal, -16)
                    .sectionContainerStyle(.opaque)
                }
                if errorMessage != nil {
                    hCoreUIAssets.warningTriangleFilled.view
                        .foregroundColor(hSignalColor.amberElement)
                        .padding(.top, 12)
                        .padding(.trailing, 16)
                }
                Rectangle()
                    .fill(Color.white.opacity(0.000001))
                    .onTapGesture {
                        showFreeTextField()
                    }
            }
            if let errorMessage {
                hText(errorMessage, style: .standardSmall).foregroundColor(hTextColor.secondary)
                    .padding(.horizontal, 16)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @hColorBuilder
    var getTextColor: some hColor {
        if value.count < 140 {
            hTextColor.tertiary
        } else {
            hSignalColor.redElement
        }
    }

    private func showFreeTextField() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}

        value = selectedValue

        let view = FreeTextInputView(
            continueAction: continueAction,
            cancelAction: cancelAction,
            value: $value,
            placeholder: placeholder,
            maxCharacters: 140
        )

        let journey = HostingJourney(
            rootView: view,
            style: .modally(presentationStyle: .overFullScreen),
            options: []
        )
        .addHero
        .addConfiguration { presenter in
            presenter.viewController.view.hero.id = "heroId"
            presenter.viewController.view.backgroundColor = .clear
        }

        let freeTextFieldJourney = journey.addConfiguration { presenter in
            continueAction.execute = {
                print("VALUE IS \(value)")
                self.value = value
                self.onContinue(value)
                presenter.dismisser(JourneyError.cancelled)
            }
            cancelAction.execute = {
                presenter.dismisser(JourneyError.cancelled)
            }
        }
        let vc = UIApplication.shared.getTopViewController()
        if let vc {
            disposeBag += vc.present(freeTextFieldJourney)
        }
    }

}

#Preview{
    @State var valuee = ""
    return VStack(spacing: 4) {
        VStack {
            hForm {}
                .hFormAttachToBottom {
                    hSection {
                        hTextView(
                            selectedValue: valuee,
                            placeholder: "placeholder",
                            required: true,
                            maxCharacters: 140
                        ) { value in
                            valuee = value
                        }
                        Rectangle()
                            .frame(height: 200)
                    }
                }
        }
    }
}

private struct FreeTextInputView: View {
    fileprivate let placeholder: String
    fileprivate let maxCharacters: Int
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    @Binding fileprivate var value: String
    @State private var height: CGFloat = 140

    public init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        value: Binding<String>,
        placeholder: String,
        maxCharacters: Int
    ) {
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self._value = value
        self.placeholder = placeholder
        self.maxCharacters = maxCharacters
    }

    public var body: some View {
        ZStack {
            hBackgroundColor.primary
                .ignoresSafeArea()
            VStack(spacing: 8) {
                hSection {
                    VStack {
                        SwiftUITextView(
                            placeholder: placeholder,
                            text: $value,
                            becomeFirstResponder: true,
                            disabled: false,
                            height: $height
                        )
                        hText("\(value.count)/\(maxCharacters)", style: .standardSmall)
                            .foregroundColor(getTextColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.vertical, 12)
                }
                hSection {
                    HStack(spacing: 8) {
                        hButton.MediumButton(type: .secondary) {
                            cancelAction.execute()
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                        hButton.MediumButton(type: .primary) {
                            //                            UIApplication.dismissKeyboard()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak continueAction] in
                                continueAction?.execute()
                            }
                        } content: {
                            hText(L10n.generalSaveButton)
                        }
                        .disabled(value.count > maxCharacters)
                    }
                    .padding(.bottom, 8)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    @hColorBuilder
    var getTextColor: some hColor {
        if value.count < maxCharacters {
            hTextColor.tertiary
        } else {
            hSignalColor.redElement
        }
    }
}

private struct DummyView: UIViewRepresentable {
    internal func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.hero.id = "heroId"
        view.layer.cornerRadius = 12
        return view
    }

    internal func updateUIView(_ uiView: UIView, context: Context) {
        let schema = UITraitCollection.current.userInterfaceStyle
        uiView.backgroundColor = hFillColor.opaqueOne.colorFor(.init(schema)!, .base).color.uiColor()
    }
}

private struct SwiftUITextView: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    let becomeFirstResponder: Bool
    let disabled: Bool
    @Binding var height: CGFloat
    internal func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let textView = TextView(
            placeholder: placeholder,
            inputText: $text,
            height: $height,
            becomeFirstResponder: becomeFirstResponder,
            disabled: disabled
        )
        textView.setText(text: text)
        view.layer.cornerRadius = 12
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
        }
        textView.updateHeight()
        return view
    }

    internal func updateUIView(_ uiView: UIView, context: Context) {
        if let textView = uiView.subviews.first as? TextView {
            if !textView.isFirstResponder {
                textView.setText(text: text)
            }
            textView.updateHeight()
        }
        let schema = UITraitCollection.current.userInterfaceStyle
        uiView.backgroundColor = hFillColor.opaqueOne.colorFor(.init(schema)!, .base).color.uiColor()

    }
}

private class TextView: UITextView, UITextViewDelegate {
    let placeholder: String
    @Binding var inputText: String
    let disabled: Bool
    @Binding var height: CGFloat
    init(
        placeholder: String,
        inputText: Binding<String>,
        height: Binding<CGFloat>,
        becomeFirstResponder: Bool,
        disabled: Bool
    ) {
        self.placeholder = placeholder
        self._inputText = inputText
        self.disabled = disabled
        self._height = height
        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(horizontalInset: 0, verticalInset: 0)
        self.delegate = self
        self.font = Fonts.fontFor(style: .standard)
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(handleDoneButtonTap)
        )
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)

        self.inputAccessoryView = toolbar
        self.setText(text: inputText.wrappedValue)
        self.isUserInteractionEnabled = !disabled
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
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if textView.text == placeholder {
            textView.text = nil
            textView.textColor = getTextColor()
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        inputText = textView.text
        self.textColor = getTextColor()
        self.updateHeight()
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
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = text
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = getTextColor()
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            // textView.resignFirstResponder() // uncomment this to close the keyboard when return key is pressed
            return false
        }

        return true
    }

    private func getTextColor() -> UIColor {
        let schema = UITraitCollection.current.userInterfaceStyle
        if text.isEmpty || placeholder == text {
            return hTextColor.tertiary.colorFor(.init(schema)!, .base).color.uiColor()
        } else {
            return hTextColor.primary.colorFor(.init(schema)!, .base).color.uiColor()
        }
    }

    func updateHeight() {
        DispatchQueue.main.async { [weak self] in guard let self = self else { return }
            withAnimation {
                self.height = self.sizeThatFits(.init(width: self.frame.width, height: .infinity)).height + 12
            }
        }
    }
}

extension JourneyPresentation {
    public var addHero: Self {
        addConfiguration { presenter in
            presenter.viewController.hero.isEnabled = true
            //            presenter.viewController.hero.modalAnimationType = .pageOut(direction: .down)
            //            presenter.viewController.hero.modalAnimationType = .uncover(direction: .down)
        }
    }
}
