import AVFAudio
import Combine
import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimAudioRecordingScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var audioRecorder: AudioRecorder

    @State var minutes: Int = 0
    @State var seconds: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let onSubmit: (_ url: URL) -> Void

    public init(
        url: URL?
    ) {
        audioPlayer = AudioPlayer(url: url)
        audioRecorder = AudioRecorder()

        func myFunc(_: URL) {}
        self.onSubmit = myFunc
    }

    public var body: some View {
        LoadingViewWithContent(.postAudioRecording) {
            hForm {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.audioRecordingStep
                    }
                ) { audioRecordingStep in
                    ForEach(audioRecordingStep?.questions ?? [], id: \.self) { question in
                        HStack {
                            hTextNew(L10nDerivation(table: "Localizable", key: question, args: []).render())
                                .foregroundColor(hLabelColorNew.primary)
                        }
                        .padding(16)
                        .background(
                            Squircle.default()
                                .fill(hBackgroundColorNew.opaqueOne)
                        )
                        .padding(.leading, 16)
                        .padding(.trailing, 88)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .hUseNewStyle
            .hFormAttachToBottom {
                ZStack(alignment: .bottom) {
                    Group {
                        if let url = audioRecorder.recording?.url ?? store.state.audioRecordingStep?.getUrl() {
                            VStack(spacing: 12) {
                                TrackPlayer(audioPlayer: audioPlayer)
                                    .hWithoutFootnote
                                    .onAppear {
                                        minutes = 0
                                        seconds = 0
                                    }
                                hButton.LargeButtonFilled {
                                    onSubmit(url)
                                    store.send(.submitAudioRecording(audioURL: url))
                                } content: {
                                    hTextNew(L10n.saveAndContinueButtonLabel)
                                }
                                hButton.LargeButtonText {
                                    withAnimation(.spring()) {
                                        store.send(.resetAudioRecording)
                                        audioRecorder.restart()
                                    }
                                } content: {
                                    hTextNew(L10n.embarkRecordAgain)
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
                                    hTextNew(L10n.claimsStartRecordingLabel, style: .body)
                                        .foregroundColor(hLabelColorNew.primary)
                                } else {
                                    let minutesToString = String(format: "%02d", minutes)
                                    let secondsToString = String(format: "%02d", seconds)
                                    hTextNew("\(minutesToString):\(secondsToString)", style: .body)
                                        .foregroundColor(hLabelColorNew.primary)
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
                        }
                    }
                    .padding(16)
                }
                .environmentObject(audioRecorder)
            }
        }
    }
}

struct SubmitClaimAudioRecordingScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimAudioRecordingScreen(url: nil)

    }
}
