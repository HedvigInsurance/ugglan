import AVFAudio
import Combine
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct EmbarkRecordAction: View {
    let data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkAudioRecorderAction.AudioRecorderDatum
    @ObservedObject var audioRecorder: AudioRecorder
    let onSubmit: (_ url: URL) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let recording = audioRecorder.recording {
                VStack(spacing: 12) {
                    TrackPlayer(audioPlayer: .init(recording: recording))
                    hButton.LargeButtonFilled {
                        guard let url = audioRecorder.recording?.url else {
                            return
                        }
                        onSubmit(url)
                    } content: {
                        hText(L10n.generalContinueButton)
                    }
                    hButton.LargeButtonText {
                        withAnimation(.spring()) {
                            audioRecorder.restart()
                        }
                    } content: {
                        hText("Record again")
                    }
                }.transition(.move(edge: .bottom))
            } else {
                RecordButton().transition(.move(edge: .bottom))
            }
        }
        .environmentObject(audioRecorder)
    }
}

struct AudioPulseBackground: View {
    @EnvironmentObject var audioRecorder: AudioRecorder

    private let backgroundColorScheme: some hColor = hColorScheme.init(
        light: hGrayscaleColor.one,
        dark: hGrayscaleColor.two
    )

    var body: some View {
        Circle().fill(backgroundColorScheme)
            .onReceive(audioRecorder.recordingTimer) { input in
                audioRecorder.refresh()
            }
            .scaleEffect(audioRecorder.isRecording ? pow(((audioRecorder.decibelScale.last ?? 0.0) + 0.95), 4) : 0.95)
            .animation(.spring())
    }
}

struct RecordButton: View {
    @EnvironmentObject var audioRecorder: AudioRecorder

    @ViewBuilder var pulseBackground: some View {
        if audioRecorder.isRecording {
            AudioPulseBackground()
        } else {
            Color.clear
        }
    }

    var body: some View {
        ZStack {
            pulseBackground
            SwiftUI.Button {
                withAnimation(.spring()) {
                    audioRecorder.toggleRecording()
                }
            } label: {

            }
            .buttonStyle(RecordButtonStyle(isRecording: audioRecorder.isRecording))
        }
    }
}

struct RecordButtonStyle: SwiftUI.ButtonStyle {
    var isRecording: Bool

    @hColorBuilder var innerCircleColor: some hColor {
        if isRecording {
            hLabelColor.primary
        } else {
            hTintColor.red
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Rectangle().fill(innerCircleColor).frame(width: 36, height: 36)
                .cornerRadius(isRecording ? 1 : 18)
                .padding(36)
        }
        .background(Circle().fill(hBackgroundColor.secondary))
        .shadow(color: .black.opacity(0.1), radius: 24, x: 0, y: 4)
    }
}
