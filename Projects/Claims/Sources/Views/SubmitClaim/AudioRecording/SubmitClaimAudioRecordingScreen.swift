import AVFAudio
import Combine
import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimAudioRecordingScreen: View {
    @PresentableStore var store: ClaimsStore
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var audioRecorder: AudioRecorder

    let onSubmit: (_ url: URL) -> Void

    public init(
        url: URL
    ) {
        audioPlayer = AudioPlayer(url: url)

        audioRecorder = AudioRecorder()

        func myFunc(_: URL) {}
        self.onSubmit = myFunc
    }

    public var body: some View {
        LoadingViewWithContent(.submitAudioRecording(audioURL: self.audioPlayer.url)) {
            hForm {
                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        state.audioRecordingStep
                    }
                ) { audioRecordingStep in
                    ForEach(audioRecordingStep?.questions ?? [], id: \.self) { question in
                        HStack(spacing: 0) {
                            hText(L10nDerivation(table: "Localizable", key: question, args: []).render())
                                .foregroundColor(hLabelColor.primary)
                                .padding([.trailing, .leading], 12)
                                .padding([.top, .bottom], 16)
                        }
                    }
                }
            }
            .hFormAttachToBottom {
                ZStack(alignment: .bottom) {
                    Group {
                        if let recording = audioRecorder.recording {
                            VStack(spacing: 12) {
                                TrackPlayer(audioPlayer: audioPlayer)

                                hButton.LargeButtonFilled {
                                    guard let url = audioRecorder.recording?.url else {
                                        return
                                    }
                                    onSubmit(url)
                                    store.send(.submitAudioRecording(audioURL: url))
                                } content: {
                                    hText(L10n.generalContinueButton)
                                }
                                hButton.LargeButtonText {
                                    withAnimation(.spring()) {
                                        audioRecorder.restart()
                                    }
                                } content: {
                                    hText(L10n.embarkRecordAgain)
                                }
                            }
                            .transition(.move(edge: .bottom))
                            .onAppear {
                                self.audioPlayer.url = recording.url
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
                            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: 0, y: 300)))
                            .padding(.top, UIScreen.main.bounds.size.height / 1.7)
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
        SubmitClaimAudioRecordingScreen(url: URL(string: "")!)
    }
}
