import AVFAudio
import Combine
import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct EmbarkRecorderTracking {
    var onPlay: hAnalyticsParcel
    var onRetry: hAnalyticsParcel
    var onSubmit: hAnalyticsParcel
    var onStop: hAnalyticsParcel
    var onStart: hAnalyticsParcel

    init(
        storyName: String,
        store: [String: String?]
    ) {
        self.onPlay = hAnalyticsEvent.embarkAudioRecordingPlayback(
            storyName: storyName,
            store: store
        )
        self.onRetry = hAnalyticsEvent.embarkAudioRecordingRetry(
            storyName: storyName,
            store: store
        )
        self.onSubmit = hAnalyticsEvent.embarkAudioRecordingSubmitted(
            storyName: storyName,
            store: store
        )
        self.onStop = hAnalyticsEvent.embarkAudioRecordingStopped(
            storyName: storyName,
            store: store
        )
        self.onStart = hAnalyticsEvent.embarkAudioRecordingBegin(
            storyName: storyName,
            store: store
        )
    }
}

struct EmbarkRecordAction: View {
    let data:
        GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkAudioRecorderAction.AudioRecorderDatum
    var tracking: EmbarkRecorderTracking
    @ObservedObject var audioRecorder: AudioRecorder
    let onSubmit: (_ url: URL) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            if let recording = audioRecorder.recording {
                VStack(spacing: 12) {
                    TrackPlayer(audioPlayer: .init(recording: recording)) {
                        tracking.onPlay.send()
                    }
                    hButton.LargeButton(type: .primary) {
                        guard let url = audioRecorder.recording?.url else {
                            return
                        }
                        tracking.onSubmit.send()
                        onSubmit(url)
                    } content: {
                        hText(L10n.generalContinueButton)
                    }
                    hButton.LargeButton(type: .ghost) {
                        tracking.onRetry.send()
                        withAnimation(.spring()) {
                            audioRecorder.restart()
                        }
                    } content: {
                        hText(L10n.embarkRecordAgain)
                    }
                }
                .transition(.move(edge: .bottom))
            } else {
                RecordButton(isRecording: audioRecorder.isRecording) {
                    if audioRecorder.isRecording {
                        tracking.onStop.send()
                    } else {
                        tracking.onStart.send()
                    }

                    withAnimation(.spring()) {
                        audioRecorder.toggleRecording()
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: 0, y: 300)))
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
    var isRecording: Bool
    var onTap: () -> Void

    @ViewBuilder var pulseBackground: some View {
        if isRecording {
            AudioPulseBackground()
        } else {
            Color.clear
        }
    }

    var body: some View {
        ZStack {
            pulseBackground
            SwiftUI.Button {
                onTap()
            } label: {

            }
            .buttonStyle(RecordButtonStyle(isRecording: isRecording))
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
