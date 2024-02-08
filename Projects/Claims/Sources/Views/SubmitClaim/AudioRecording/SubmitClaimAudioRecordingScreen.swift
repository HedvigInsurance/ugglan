import AVFAudio
import Combine
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimAudioRecordingScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var audioRecorder: AudioRecorder
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var isAudioInput = true
    @State var inputText: String = ""
    @State var inputTextError: String?
    @State var animateField: Bool = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let onSubmit: (_ url: URL) -> Void

    public init(
        url: URL?
    ) {
        audioPlayer = AudioPlayer(url: url)
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let path = store.state.claimAudioRecordingPath
        audioRecorder = AudioRecorder(filePath: path)

        func myFunc(_: URL) {}
        self.onSubmit = myFunc
    }

    public var body: some View {
        if isAudioInput {
            audioInputForm
        } else {
            textInputForm
        }
    }

    private var audioInputForm: some View {
        hForm {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.audioRecordingStep
                }
            ) { audioRecordingStep in
                if isAudioInput {
                    VStack(spacing: 8) {
                        ForEach(Array((audioRecordingStep?.questions ?? []).enumerated()), id: \.element) {
                            index,
                            question in
                            HStack {
                                hText(L10nDerivation(table: "Localizable", key: question, args: []).render())
                                    .foregroundColor(hTextColor.primary)
                            }
                            .padding(16)
                            .background(
                                Squircle.default()
                                    .fill(hFillColor.opaqueOne)
                            )
                            .padding(.leading, 16)
                            .padding(.trailing, 88)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .slideUpAppearAnimation()
                        }
                    }
                    .padding(.top, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(Array((audioRecordingStep?.textQuestions ?? []).enumerated()), id: \.element) {
                            index,
                            question in
                            HStack {
                                hText(L10nDerivation(table: "Localizable", key: question, args: []).render())
                                    .foregroundColor(hTextColor.primary)
                            }
                            .padding(16)
                            .background(
                                Squircle.default()
                                    .fill(hFillColor.opaqueOne)
                            )
                            .padding(.leading, 16)
                            .padding(.trailing, 88)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .slideUpAppearAnimation()

                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .hDisableScroll
        .hFormAttachToBottom {
            audioElements
                .slideUpAppearAnimation()
        }
    }

    private var textInputForm: some View {
        hForm {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.audioRecordingStep
                }
            ) { audioRecordingStep in
                if isAudioInput {
                    ForEach(Array((audioRecordingStep?.questions ?? []).enumerated()), id: \.element) {
                        index,
                        question in
                        HStack {
                            hText(L10nDerivation(table: "Localizable", key: question, args: []).render())
                                .foregroundColor(hTextColor.primary)
                        }
                        .padding(16)
                        .background(
                            Squircle.default()
                                .fill(hFillColor.opaqueOne)
                        )
                        .padding(.vertical, 12)
                        .padding(.leading, 16)
                        .padding(.trailing, 88)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .slideUpAppearAnimation()
                    }
                } else {
                    ForEach(Array((audioRecordingStep?.textQuestions ?? []).enumerated()), id: \.element) {
                        index,
                        question in
                        HStack {
                            hText(L10nDerivation(table: "Localizable", key: question, args: []).render())
                                .foregroundColor(hTextColor.primary)
                        }
                        .padding(16)
                        .background(
                            Squircle.default()
                                .fill(hFillColor.opaqueOne)
                        )
                        .padding(.vertical, 12)
                        .padding(.leading, 16)
                        .padding(.trailing, 88)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .slideUpAppearAnimation()

                    }
                }
            }
        }
        .hDisableScroll
        .hFormAttachToBottom {
            textElements
                .slideUpAppearAnimation()

        }
    }

    private var audioElements: some View {
        ZStack(alignment: .bottom) {
            Group {
                if let url = audioRecorder.recording?.url ?? store.state.audioRecordingStep?.getUrl() {
                    VStack(spacing: 12) {
                        TrackPlayer(audioPlayer: audioPlayer)
                            .onAppear {
                                minutes = 0
                                seconds = 0
                            }
                        hButton.LargeButton(type: .primary) {
                            onSubmit(url)
                            store.send(.submitAudioRecording(type: .audio(url: url)))
                        } content: {
                            hText(L10n.saveAndContinueButtonLabel)
                        }
                        .trackLoading(SubmitClaimStore.self, action: .postAudioRecording)
                        hButton.LargeButton(type: .ghost) {
                            withAnimation(.spring()) {
                                store.send(.resetAudioRecording)
                                audioRecorder.restart()
                            }
                        } content: {
                            hText(L10n.embarkRecordAgain)
                        }
                        .disableOn(SubmitClaimStore.self, [.postAudioRecording])
                    }
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        self.audioPlayer.url = url
                    }
                } else {
                    VStack(spacing: 0) {
                        RecordButton(isRecording: audioRecorder.isRecording) {
                            if audioRecorder.isRecording {
                            } else {
                            }
                            withAnimation(.spring()) {
                                audioRecorder.toggleRecording()
                            }
                        }
                        .frame(height: audioRecorder.isRecording ? 144 : 72)
                        .padding(.bottom, audioRecorder.isRecording ? 10 : 46)
                        .transition(
                            .asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: 0, y: 300))
                        )
                        if !audioRecorder.isRecording {
                            PresentableStoreLens(
                                SubmitClaimStore.self,
                                getter: { state in
                                    state.audioRecordingStep
                                }
                            ) { audioRecordingStep in
                                if audioRecordingStep?.optionalAudio == true {
                                    hButton.LargeButton(type: .ghost) {
                                        withAnimation {
                                            self.isAudioInput = false
                                        }
                                    } content: {
                                        hText(L10n.claimsUseTextInstead, style: .body)
                                            .foregroundColor(hTextColor.primary)
                                    }

                                } else {
                                    hText(L10n.claimsStartRecordingLabel, style: .body)
                                        .foregroundColor(hTextColor.primary)

                                }
                            }
                        } else {
                            let minutesToString = String(format: "%02d", minutes)
                            let secondsToString = String(format: "%02d", seconds)
                            hText("\(minutesToString):\(secondsToString)", style: .body)
                                .foregroundColor(hTextColor.primary)
                                .onReceive(timer) { time in
                                    if ((seconds % 59) == 0) && seconds != 0 {
                                        minutes += 1
                                        seconds = 0
                                    } else {
                                        seconds += 1
                                    }
                                }
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .environmentObject(audioRecorder)
    }

    private var textElements: some View {
        VStack(spacing: 16) {
            textField
            hButton.LargeButton(type: .primary) {
                UIApplication.dismissKeyboard()
                if validate() {
                    store.send(.submitAudioRecording(type: .text(text: inputText)))
                }
            } content: {
                hText(L10n.saveAndContinueButtonLabel)
            }
            .trackLoading(SubmitClaimStore.self, action: .postAudioRecording)

            hButton.LargeButton(type: .ghost) {
                withAnimation {
                    self.isAudioInput = true
                }
            } content: {
                hText(L10n.claimsUseAudioRecording, style: .body)
            }
            .disableOn(SubmitClaimStore.self, [.postAudioRecording])
        }
        .padding(16)
        .frame(height: 300)
    }
    @ViewBuilder
    private var textField: some View {
        CustomTextViewRepresentable(placeholder: L10n.claimsTextInputPlaceholder, text: $inputText)
            .cornerRadius(12)
            .frame(height: 128)
            .padding(.vertical, 16)
            .addFieldError(animate: $animateField, error: $inputTextError)
    }

    private func validate() -> Bool {
        withAnimation {
            let minCharacters = 50
            print(self.inputText.count)
            if self.inputText.count < minCharacters {
                inputTextError = L10n.claimsTextInputMinCharactersError(minCharacters)
            } else {
                inputTextError = nil
            }
        }
        return inputTextError == nil
    }
}

//struct SubmitClaimAudioRecordingScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        SubmitClaimAudioRecordingScreen(url: nil)
//            .onAppear {
//                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
//                let graphQL = OctopusGraphQL.FlowClaimAudioRecordingStepFragment(
//                    id: "id",
//                    questions: ["question 1"],
//                    freeText: nil,
//                    freeTextQuestions: [],
//                    freeTextAvailable: true
//                )
//                let model = FlowClaimAudioRecordingStepModel(with: graphQL)
//                store.send(.stepModelAction(action: .setAudioStep(model: model)))
//            }
//    }
//}

struct CustomTextViewRepresentable: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    public func makeUIView(context: Context) -> some UIView {
        CustomTextView(placeholder: placeholder, inputText: $text)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

private class CustomTextView: UITextView, UITextViewDelegate {
    let placeholder: String
    @Binding var inputText: String

    init(placeholder: String, inputText: Binding<String>) {
        self.placeholder = placeholder
        self._inputText = inputText
        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(horizontalInset: 4, verticalInset: 4)
        self.delegate = self
        self.font = Fonts.fontFor(style: .standard)
        if inputText.wrappedValue.isEmpty {
            self.text = placeholder
            self.textColor = UIColor.lightGray
        } else {
            self.text = inputText.wrappedValue
            self.textColor = UIColor.black
        }
        self.backgroundColor = UIColor(hFillColor.opaqueOne.colorFor(.light, .base).color)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(handleDoneButtonTap)
        )
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)

        self.inputAccessoryView = toolbar
    }

    @objc private func handleDoneButtonTap() {
        self.resignFirstResponder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = text
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
    }
}
