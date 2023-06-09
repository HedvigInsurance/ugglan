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

    let onSubmit: (_ url: URL) -> Void

    public init(
        //        url: URL?
        url: URL? = URL(string: "")
    ) {
        audioPlayer = AudioPlayer(url: url)

        audioRecorder = AudioRecorder()

        func myFunc(_: URL) {}
        self.onSubmit = myFunc
    }

    public var body: some View {
        LoadingViewWithContent(.postAudioRecording) {
            hForm {
            }
            .hUseNewStyle
            .hFormAttachToBottom {
                VStack {

                    PresentableStoreLens(
                        SubmitClaimStore.self,
                        getter: { state in
                            state.audioRecordingStep
                        }
                    ) { audioRecordingStep in
                        ForEach(audioRecordingStep?.questions ?? [], id: \.self) { question in
                            hSection {
                                hRow {
                                    hTextNew(L10nDerivation(table: "Localizable", key: question, args: []).render())
                                        .foregroundColor(hLabelColorNew.primary)
                                }
                            }
                        }
                    }

                    ZStack(alignment: .bottom) {
                        Group {
                            if let url = audioRecorder.recording?.url ?? store.state.audioRecordingStep?.getUrl() {
                                VStack(spacing: 12) {
                                    TrackPlayer(audioPlayer: audioPlayer)
                                        .hUseNewStyle
                                        .hWithoutFootnote
                                    hButton.LargeButtonFilled {
                                        onSubmit(url)
                                        store.send(.submitAudioRecording(audioURL: url))
                                    } content: {
                                        hText(L10n.generalContinueButton)
                                    }
                                    hButton.LargeButtonText {
                                        withAnimation(.spring()) {
                                            store.send(.resetAudioRecording)
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

                                RecordButton(isRecording: audioRecorder.isRecording) {
                                    if audioRecorder.isRecording {
                                    } else {
                                    }
                                    withAnimation(.spring()) {
                                        audioRecorder.toggleRecording()
                                    }
                                }
                                .hUseNewStyle
                                .frame(height: 112)
                                .transition(
                                    .asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: 0, y: 300))
                                )
                            }
                        }
                        .padding(16)
                    }
                    .environmentObject(audioRecorder)
                }
            }
        }
    }
}

struct SubmitClaimAudioRecordingScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimAudioRecordingScreen()
    }
}
