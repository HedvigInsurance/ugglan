import SwiftUI
import hCore
import hCoreUI

struct TrackPlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    var body: some View {
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
