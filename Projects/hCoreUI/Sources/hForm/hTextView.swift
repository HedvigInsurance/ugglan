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
    @Environment(\.hTextFieldError) var errorMessage
    @State private var value: String = ""
    @State private var disposeBag = DisposeBag()
    @State private var selectedValue: String = ""
    @State private var popoverHeight: CGFloat = 0

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
                HeroAnimationStartView {
                    hSection {
                        VStack(spacing: 0) {
                            SwiftUITextView(
                                placeholder: placeholder,
                                text: $selectedValue,
                                becomeFirstResponder: false,
                                disabled: true,
                                height: $height
                            )
                            .frame(height: height)
                            hText("\(selectedValue.count)/\(maxCharacters)", style: .standardSmall)
                                .foregroundColor(getTextColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 12)
                    }
                    .padding(.horizontal, -16)
                    .sectionContainerStyle(.opaque)
                }
                .id(UUID().uuidString)
                .frame(height: height + 52)
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
        if selectedValue.count < 140 {
            hTextColor.tertiary
        } else {
            hSignalColor.redElement
        }
    }

    private func showFreeTextField() {
        let continueAction = ReferenceAction {}
        let cancelAction = ReferenceAction {}

        value = selectedValue

        let view = HeroAnimationDestinationView {
            FreeTextInputView(
                continueAction: continueAction,
                cancelAction: cancelAction,
                value: $value,
                placeholder: placeholder,
                maxCharacters: maxCharacters,
                height: $popoverHeight
            )
        }

        let journey = HostingJourney(
            rootView: view,
            style: .modally(presentationStyle: .overFullScreen),
            options: []

        )
        .enableHero
        .addConfiguration { presenter in
            presenter.viewController.view.backgroundColor = .clear
        }

        let freeTextFieldJourney = journey.addConfiguration { presenter in
            continueAction.execute = {
                self.selectedValue = value
                self.height = popoverHeight
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
                    VStack(spacing: 0) {
                        Rectangle().frame(height: 20)
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

private struct FreeTextInputView: View {
    fileprivate let placeholder: String
    fileprivate let maxCharacters: Int
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    @Binding fileprivate var value: String
    @Binding private var height: CGFloat
    @State var showButtons = false
    public init(
        continueAction: ReferenceAction,
        cancelAction: ReferenceAction,
        value: Binding<String>,
        placeholder: String,
        maxCharacters: Int,
        height: Binding<CGFloat>
    ) {
        self.continueAction = continueAction
        self.cancelAction = cancelAction
        self._value = value
        self.placeholder = placeholder
        self.maxCharacters = maxCharacters
        self._height = height
    }

    public var body: some View {
        ZStack {
            BackgroundView().ignoresSafeArea()
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
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                }
                if showButtons {
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
                            .padding(.bottom, 8)
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .onAppear {

            withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                showButtons = true
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
            if disabled {
                textView.setText(text: text)
                textView.updateHeight()
            }
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
        if disabled {
            let ss = text
        }
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
            textView.resignFirstResponder()
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
                let newHeight = self.sizeThatFits(.init(width: self.frame.width, height: .infinity)).height + 12
                if self.frame.width > 0 {
                    self.height = newHeight
                }
            }
        }
    }
}
