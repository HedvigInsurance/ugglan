import AVFAudio
import Speech
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatInputView: View {
    @ObservedObject var viewModel: SubmitClaimChatInputViewModel
    @State var height: CGFloat = 0
    let placeHolder: String

    var body: some View {
        HStack {
            CustomTextViewRepresentable(
                placeholder: placeHolder,
                text: $viewModel.inputText,
                height: $height,
                keyboardIsShown: $viewModel.keyboardIsShown,
                onSend: { viewModel.sendTextMessage() }
            )
            .frame(height: height)
            .frame(minHeight: 40)

            Spacer()
            hCoreUIAssets.mic.view
                .foregroundColor(recordingColor)
                .onTapGesture { viewModel.isRecording.toggle() }
        }
        .padding(.horizontal, .padding16)
        .padding(.vertical, .padding8)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(hSurfaceColor.Opaque.secondary)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL))
        .padding(.horizontal, .padding16)
        //        .onChange(of: viewModel.isRecording) { rec in
        //            if rec { viewModel.startRecording() } else { viewModel.stopRecording() }
        //        }
        //        .onDisappear { viewModel.stopRecording() }
    }

    @hColorBuilder
    var recordingColor: some hColor {
        if viewModel.isRecording { hSignalColor.Red.element } else { hTextColor.Opaque.primary }
    }
}

@MainActor
class SubmitClaimChatInputViewModel: NSObject, ObservableObject {
    @Published var inputText: String = ""
    @Published var isRecording: Bool = false
    @Published var keyboardIsShown = false
}

@MainActor
extension SubmitClaimChatInputViewModel: AVAudioRecorderDelegate {
    func sendTextMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
    }
}

struct CustomTextViewRepresentable: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var keyboardIsShown: Bool
    @Environment(\.colorScheme) var schema
    var onSend: (() -> Void)? = nil

    func makeUIView(context _: Context) -> some UIView {
        CustomTextView(
            placeholder: placeholder,
            inputText: $text,
            height: $height,
            keyboardIsShown: $keyboardIsShown,
            onSend: onSend
        )
    }

    func updateUIView(_ uiView: UIViewType, context _: Context) {
        guard let tv = uiView as? CustomTextView else { return }

        tv.setPlaceholder(placeholder)

        if tv.text != text {
            tv.text = text
            if tv.isFirstResponder == false {
                let end = (tv.text as NSString).length
                tv.selectedRange = NSRange(location: end, length: 0)
            }
            tv.updateHeight()
        }
        tv.updateColors()
    }
}

@MainActor
private class CustomTextView: UITextView, UITextViewDelegate {
    @Binding private var inputText: String
    @Binding private var height: CGFloat
    @Binding private var keyboardIsShown: Bool
    private var placeholderLabel = UILabel()
    private var onSend: (() -> Void)?

    init(
        placeholder: String,
        inputText: Binding<String>,
        height: Binding<CGFloat>,
        keyboardIsShown: Binding<Bool>,
        onSend: (() -> Void)? = nil
    ) {
        _inputText = inputText
        _height = height
        _keyboardIsShown = keyboardIsShown
        self.onSend = onSend
        super.init(frame: .zero, textContainer: nil)
        textContainerInset = .init(top: 4, left: 4, bottom: 4, right: 4)
        delegate = self
        isScrollEnabled = false
        font = Fonts.fontFor(style: .body1)
        text = inputText.wrappedValue
        textColor = UIColor.black
        backgroundColor = .clear

        placeholderLabel.font = Fonts.fontFor(style: .body1)
        placeholderLabel.text = placeholder
        addSubview(placeholderLabel)
        placeholderLabel.accessibilityElementsHidden = true
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(8)
        }
        accessibilityLabel = placeholderLabel.text

        updateColors()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setPlaceholder(_ text: String) {
        if placeholderLabel.text != text {
            placeholderLabel.text = text
            accessibilityLabel = text
        }
        // visibility still driven by emptiness of the actual text
    }

    func textViewDidBeginEditing(_: UITextView) { keyboardIsShown = true }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            onSend?()
            return false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.inputText = textView.text
            self?.updateHeight()
            self?.updateColors()
        }
        return true
    }

    func textViewDidEndEditing(_: UITextView) { keyboardIsShown = false }

    func updateHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            withAnimation {
                self.height = min(self.contentSize.height, 150)
            }
        }
    }

    func updateColors() {
        placeholderLabel.isHidden = !(self.text?.isEmpty ?? true)
        placeholderLabel.textColor = placeholderTextColor
        textColor = editingTextColor
    }

    private var editingTextColor: UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return hTextColor.Opaque.primary.colorFor(colorScheme, .base).color.uiColor()
    }

    private var placeholderTextColor: UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return hTextColor.Opaque.secondary.colorFor(colorScheme, .base).color.uiColor()
    }
}
