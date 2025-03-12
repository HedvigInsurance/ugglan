import SwiftUI
import hCore

public struct TrackPlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    public init(
        audioPlayer: AudioPlayer
    ) {
        self.audioPlayer = audioPlayer
    }

    public var body: some View {
        switch audioPlayer.playbackState {
        case .error:
            InfoCard(text: L10n.ClaimStatusDetail.InfoError.body, type: .attention)
                .buttons([
                    .init(
                        buttonTitle: L10n.ClaimStatusDetail.InfoError.button,
                        buttonAction: {
                            audioPlayer.togglePlaying()
                        }
                    )
                ])
        default:
            TrackPlayer(
                audioPlayer: audioPlayer
            )
            .accessibilityElement(children: .combine)
            .accessibilityRemoveTraits(.isImage)
            .accessibilityAddTraits(.playsSound)
            .accessibilityHint(L10n.voiceoverAudioRecordingPlay)
        }
    }
}
