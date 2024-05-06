import Flow
import Foundation
import Presentation
import SwiftUI
import hCore

public struct hTextView: View {
    private let placeholder: String
    private let selectedValue: String
    private let required: Bool
    private let maxCharacters: Int
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
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                hSection {
                    VStack {
                        SwiftUITextView(
                            placeholder: placeholder,
                            text: .constant(selectedValue),
                            becomeFirstResponder: false,
                            disabled: true
                        )
                        .padding(.horizontal, -2)
                        .padding(.vertical, -2)
                        hText("\(value.count)/\(maxCharacters)", style: .standardSmall)
                            .foregroundColor(getTextColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 16)
                    }
                    .padding([.horizontal], 16)
                    .padding(.vertical, 12)
                }
                .sectionContainerStyle(.opaque)
                .padding(.horizontal, -16)
                .padding(.vertical, -8)
                if let errorMessage {
                    hText(errorMessage, style: .standardSmall)
                        .foregroundColor(hTextColor.secondary)
                }
            }
            .padding(.vertical, 12)
            if errorMessage != nil {
                hCoreUIAssets.warningTriangleFilled.view
                    .foregroundColor(hSignalColor.amberElement)
                    .padding(.top, 12)
                    .padding(.trailing, 16)
            }
            Rectangle().fill(Color.white.opacity(0.000001))
                .onTapGesture {
                    showFreeTextField()
                }
        }
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
    VStack(spacing: 4) {
        hTextView(
            selectedValue: "value",
            placeholder: "placeholder",
            required: true,
            maxCharacters: 140
        )
    }
}

private struct FreeTextInputView: View {
    fileprivate let placeholder: String
    fileprivate let maxCharacters: Int
    fileprivate let continueAction: ReferenceAction
    fileprivate let cancelAction: ReferenceAction
    @Binding fileprivate var value: String

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
        VStack(spacing: 16) {
            hSection {
                VStack {
                    SwiftUITextView(
                        placeholder: placeholder,
                        text: $value,
                        becomeFirstResponder: true,
                        disabled: false
                    )
                    hText("\(value.count)/\(maxCharacters)", style: .standardSmall)
                        .foregroundColor(getTextColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding([.horizontal], 16)
                .padding(.vertical, 12)
            }
            HStack(spacing: 8) {
                hButton.MediumButton(type: .primary) {
                    continueAction.execute()
                } content: {
                    hText(L10n.generalSaveButton)
                }
                .disabled(value.count > maxCharacters)
                hButton.MediumButton(type: .ghost) {
                    cancelAction.execute()
                } content: {
                    hText(L10n.generalCancelButton)
                }
            }
            .padding(.horizontal, 16)
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
    internal func makeUIView(context: Context) -> TextView {
        let textView = TextView(
            placeholder: placeholder,
            inputText: $text,
            becomeFirstResponder: becomeFirstResponder,
            disabled: disabled
        )
        textView.setText(text: text)
        return textView
    }

    internal func updateUIView(_ uiView: TextView, context: Context) {
        if !uiView.isFirstResponder {
            uiView.setText(text: text)
        }
    }
}

private class TextView: UITextView, UITextViewDelegate {
    let placeholder: String
    @Binding var inputText: String
    let disabled: Bool

    init(
        placeholder: String,
        inputText: Binding<String>,
        becomeFirstResponder: Bool,
        disabled: Bool
    ) {
        self.placeholder = placeholder
        self._inputText = inputText
        self.disabled = disabled

        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(horizontalInset: 0, verticalInset: 0)
        self.delegate = self
        self.font = Fonts.fontFor(style: .standard)
        self.backgroundColor = UIColor.clear
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
    }

    func setText(text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let schema = UITraitCollection.current.userInterfaceStyle
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

    private func getTextColor() -> UIColor {
        let schema = UITraitCollection.current.userInterfaceStyle
        if text.isEmpty || placeholder == text {
            return hTextColor.tertiary.colorFor(.init(schema)!, .base).color.uiColor()
        } else {
            return hTextColor.primary.colorFor(.init(schema)!, .base).color.uiColor()
        }
    }
}
