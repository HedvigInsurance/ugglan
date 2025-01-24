import AVFAudio
import Combine
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimAudioRecordingScreen: View {
    @ObservedObject var claimsNavigationVm: ClaimsNavigationViewModel
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var audioRecorder: AudioRecorder
    @StateObject var audioRecordingVm = SubmitClaimAudioRecordingScreenModel()

    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var isAudioInput = true
    @State var inputText: String = ""
    @State var inputTextError: String?
    @State var animateField: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let onSubmit: (_ url: URL) -> Void

    public init(
        url: URL?,
        claimsNavigationVm: ClaimsNavigationViewModel
    ) {
        audioPlayer = AudioPlayer(url: url)
        self.claimsNavigationVm = claimsNavigationVm
        let path = claimsNavigationVm.claimAudioRecordingPath
        audioRecorder = AudioRecorder(filePath: path)
        self._isAudioInput = State(initialValue: claimsNavigationVm.audioRecordingModel?.isAudioInput() ?? false)
        let inputText: String? = {
            if claimsNavigationVm.audioRecordingModel?.optionalAudio == false {
                return nil
            }
            return claimsNavigationVm.audioRecordingModel?.inputTextContent
        }()
        self._inputText = State(initialValue: inputText ?? "")
        func myFunc(_: URL) {}
        self.onSubmit = myFunc
    }

    public var body: some View {
        if isAudioInput {
            mainContent
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
        } else {
            mainContent
        }

    }

    private var mainContent: some View {
        hForm {
            let audioRecordingStep = claimsNavigationVm.audioRecordingModel
            if isAudioInput {
                textSection(questions: audioRecordingStep?.questions)
            } else {
                textSection(questions: audioRecordingStep?.textQuestions)
            }
        }
        .hFormAlwaysAttachToBottom {
            Group {
                if isAudioInput {
                    audioElements
                } else {
                    textElements
                }
            }
            .slideUpAppearAnimation()
        }
        .claimErrorTrackerForState($audioRecordingVm.viewState)
    }

    private func textSection(questions: [String]?) -> some View {
        hSection {
            VStack(spacing: 8) {
                if let questions = questions {
                    ForEach(questions, id: \.self) { question in
                        hText(L10nDerivation(table: "Localizable", key: question, args: []).render())
                            .foregroundColor(hTextColor.Opaque.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.padding16)
                            .background(hSurfaceColor.Opaque.primary)
                            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                            .padding(.trailing, .padding88)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .slideUpAppearAnimation()
                    }
                }
            }
            .padding(.top, .padding8)
        }
        .sectionContainerStyle(.transparent)
    }

    private var audioElements: some View {
        hSection {
            ZStack(alignment: .bottom) {
                Group {
                    if let url = audioRecorder.recording?.url ?? claimsNavigationVm.audioRecordingModel?.getUrl() {
                        VStack(spacing: 12) {
                            TrackPlayerView(audioPlayer: audioPlayer)
                                .onAppear {
                                    minutes = 0
                                    seconds = 0
                                }
                            hButton.LargeButton(type: .primary) {
                                onSubmit(url)
                                Task {
                                    if let model = claimsNavigationVm.audioRecordingModel {
                                        let step = await audioRecordingVm.submitAudioRecording(
                                            context: claimsNavigationVm.currentClaimContext ?? "",
                                            currentClaimId: claimsNavigationVm.currentClaimId ?? "",
                                            type: .audio(url: url),
                                            model: model
                                        )

                                        if let step {
                                            claimsNavigationVm.navigate(data: step)
                                        }
                                    }
                                }
                            } content: {
                                hText(L10n.saveAndContinueButtonLabel)
                            }
                            .disabled(audioRecordingVm.viewState == .loading)
                            .hButtonIsLoading(audioRecordingVm.viewState == .loading)
                            hButton.LargeButton(type: .ghost) {
                                withAnimation(.spring()) {
                                    claimsNavigationVm.audioRecordingModel?.audioContent = nil
                                    audioRecorder.restart()
                                }
                            } content: {
                                hText(L10n.embarkRecordAgain)
                            }
                        }
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
                                let audioRecordingStep = claimsNavigationVm.audioRecordingModel
                                if audioRecordingStep?.optionalAudio == true {
                                    hButton.LargeButton(type: .ghost) {
                                        withAnimation {
                                            self.isAudioInput = false
                                        }
                                    } content: {
                                        hText(L10n.claimsUseTextInstead, style: .body1)
                                            .foregroundColor(hTextColor.Opaque.primary)
                                    }

                                } else {
                                    hText(L10n.claimsStartRecordingLabel, style: .body1)
                                        .foregroundColor(hTextColor.Opaque.primary)

                                }
                            } else {
                                let minutesToString = String(format: "%02d", minutes)
                                let secondsToString = String(format: "%02d", seconds)
                                hText("\(minutesToString):\(secondsToString)", style: .body1)
                                    .foregroundColor(hTextColor.Opaque.primary)
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
                        .accessibilityElement(children: .combine)
                        .accessibilityHint(
                            audioRecorder.isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel
                        )
                    }
                }
            }
            .environmentObject(audioRecorder)
        }
        .sectionContainerStyle(.transparent)
    }

    private var textElements: some View {
        VStack(spacing: 16) {
            textField
            hSection {
                hButton.LargeButton(type: .primary) {
                    UIApplication.dismissKeyboard()
                    if validate() {
                        Task {
                            if let model = claimsNavigationVm.audioRecordingModel {
                                let step = await audioRecordingVm.submitAudioRecording(
                                    context: claimsNavigationVm.currentClaimContext ?? "",
                                    currentClaimId: claimsNavigationVm.currentClaimId ?? "",
                                    type: .text(text: inputText),
                                    model: model
                                )

                                if let step {
                                    claimsNavigationVm.navigate(data: step)
                                }
                            }
                        }
                    }
                } content: {
                    hText(L10n.saveAndContinueButtonLabel)
                }
                hButton.LargeButton(type: .ghost) {
                    withAnimation {
                        self.isAudioInput = true
                    }
                } content: {
                    hText(L10n.claimsUseAudioRecording, style: .body1)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .frame(height: 300)
    }

    @ViewBuilder
    private var textField: some View {
        hSection {
            hTextView(
                selectedValue: inputText,
                placeholder: L10n.claimsTextInputPlaceholder,
                required: true,
                maxCharacters: 2000
            ) { text in
                inputText = text
                inputTextError = nil
            }
            .hTextFieldError(inputTextError)
        }
        .sectionContainerStyle(.transparent)
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

@MainActor
public class SubmitClaimAudioRecordingScreenModel: ObservableObject {
    private let service = SubmitClaimService()
    @Published public var viewState: ProcessingState = .success

    @MainActor
    func submitAudioRecording(
        context: String,
        currentClaimId: String,
        type: SubmitAudioRecordingType,
        model: FlowClaimAudioRecordingStepModel
    ) async -> SubmitClaimStepResponse? {
        withAnimation {
            self.viewState = .loading
        }

        do {
            let data = try await service.submitAudioRecording(
                type: type,
                context: context,
                currentClaimId: currentClaimId,
                model: model
            )

            withAnimation {
                self.viewState = .success
            }

            return data
        } catch let exception {
            withAnimation {
                self.viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
        return nil
    }
}

struct SubmitClaimAudioRecordingScreen_Previews: PreviewProvider {

    static var previews: some View {
        let client = FetchEntrypointsClientDemo()
        Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in client })
        let navigation = ClaimsNavigationViewModel()
        navigation.audioRecordingModel = .init(
            id: "id",
            questions: [
                "QUESTGION 1 very long how much time it should take to complete this task"
            ],
            textQuestions: [],
            inputTextContent: nil,
            optionalAudio: false
        )
        return SubmitClaimAudioRecordingScreen(
            url: URL(string: "https://filesamples.com/samples/audio/m4a/sample4.m4a"),
            claimsNavigationVm: navigation
        )
    }
}
