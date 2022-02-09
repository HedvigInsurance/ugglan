import SwiftUI
import hCore
import hCoreUI

struct ClaimDetailFilesView: View {
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
