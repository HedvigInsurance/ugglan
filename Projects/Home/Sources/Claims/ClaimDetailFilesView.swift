import SwiftUI
import hCore
import hCoreUI

struct ClaimDetailFilesView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    var body: some View {
        switch audioPlayer.playbackState {
        case .error:
            PlaybackFailedView()
        default:
            TrackPlayer(
                audioPlayer: audioPlayer
            )
        }
    }
}
