import AVFAudio
import Combine
import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimAudioRecordingScreen: View {
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var audioRecorder: AudioRecorder
    @StateObject var audioRecordingVm = SubmitClaimAudioRecordingScreenModel()

    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var isAudioInput = true
    @State var inputText: String = ""
    @State var inputTextError: String?
    @AccessibilityFocusState private var saveAndContinueFocused: Bool

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let onSubmit: (_ url: URL) -> Void

    public init(
        url: URL?,
        claimsNavigationVm: SubmitClaimNavigationViewModel
    ) {
        audioPlayer = AudioPlayer(url: url)
        self.claimsNavigationVm = claimsNavigationVm
        let path = claimsNavigationVm.claimAudioRecordingPath
        audioRecorder = AudioRecorder(filePath: path)
        _isAudioInput = State(initialValue: claimsNavigationVm.audioRecordingModel?.isAudioInput() ?? false)
        let inputText: String? = {
            if claimsNavigationVm.audioRecordingModel?.optionalAudio == false {
                return nil
            }
            return claimsNavigationVm.audioRecordingModel?.inputTextContent
        }()
        _inputText = State(initialValue: inputText ?? "")
        func myFunc(_: URL) {}
        onSubmit = myFunc
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
            .expandAppearAnimation()
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
        .accessibilityElement(children: .combine)
    }

    private var audioElements: some View {
        hSection {
            ZStack(alignment: .bottom) {
                Group {
                    if let url = audioRecorder.recording?.url ?? claimsNavigationVm.audioRecordingModel?.getUrl() {
                        playRecordingButton(url: url)
                    } else {
                        recordNewButton
                    }
                }
            }
            .environmentObject(audioRecorder)
        }
        .sectionContainerStyle(.transparent)
    }

    private func playRecordingButton(url: URL) -> some View {
        VStack(spacing: .padding12) {
            TrackPlayerView(audioPlayer: audioPlayer)
                .onAppear {
                    minutes = 0
                    seconds = 0
                }

            hButton(
                .large,
                .primary,
                content: .init(title: L10n.saveAndContinueButtonLabel),
                {
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
                }
            )
            .disabled(audioRecordingVm.viewState == .loading)
            .hButtonIsLoading(audioRecordingVm.viewState == .loading)
            .accessibilityFocused($saveAndContinueFocused)
            .accessibilityLabel(Text(L10n.saveAndContinueButtonLabel))

            hButton(
                .large,
                .ghost,
                content: .init(title: L10n.embarkRecordAgain),
                {
                    withAnimation(.spring()) {
                        claimsNavigationVm.audioRecordingModel?.audioContent = nil
                        audioRecorder.restart()
                    }
                }
            )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            audioPlayer.url = url
        }
    }

    private var recordNewButton: some View {
        VStack(spacing: 0) {
            RecordButton(isRecording: audioRecorder.isRecording) {
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
                    hButton(
                        .large,
                        .ghost,
                        content: .init(title: L10n.claimsUseTextInstead),
                        {
                            withAnimation {
                                isAudioInput = false
                            }
                        }
                    )
                } else {
                    hText(L10n.claimsStartRecordingLabel, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                }
            } else {
                let minutesToString = String(format: "%02d", minutes)
                let secondsToString = String(format: "%02d", seconds)
                hText("\(minutesToString):\(secondsToString)", style: .body1)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .onReceive(timer) { _ in
                        if (seconds % 59) == 0, seconds != 0 {
                            minutes += 1
                            seconds = 0
                        } else {
                            seconds += 1
                        }
                    }
            }
        }
        .onChange(of: audioRecorder.isRecording) { isRecording in
            if !isRecording {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIAccessibility.post(notification: .announcement, argument: " ")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        saveAndContinueFocused = true
                    }
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityHint(
            audioRecorder.isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel
        )
    }

    private var textElements: some View {
        VStack(spacing: .padding16) {
            textField
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.saveAndContinueButtonLabel),
                    {
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
                    }
                )
                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.claimsUseAudioRecording),
                    {
                        withAnimation {
                            isAudioInput = true
                        }
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder
    private var textField: some View {
        hSection {
            hTextView(
                selectedValue: inputText,
                placeholder: L10n.claimsTextInputPlaceholder,
                popupPlaceholder: L10n.claimsTextInputPopoverPlaceholder,
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
            if inputText.count < minCharacters {
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

#Preview {
    let client = FetchEntrypointsClientDemo()
    Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in client })
    let navigation = SubmitClaimNavigationViewModel()
    navigation.audioRecordingModel = .init(
        questions: [
            "QUESTION 1 very long how much time it should take to complete this task"
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
