import SwiftUI
import hCore
import hCoreUI

struct TrackPlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    var body: some View {
        switch audioPlayer.playbackState {
        case .error:
            PlaybackFailedView {
                audioPlayer.togglePlaying()
            }
        default:
            TrackPlayer(
                audioPlayer: audioPlayer
            )
        }
    }
}
