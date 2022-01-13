import SwiftUI
import hCore
import hCoreUI

struct ClaimDetailFilesView: View {
    let signedAudioURL: String

    var body: some View {
        if let url = URL(string: signedAudioURL) {
            TrackPlayer(
                audioPlayer: AudioPlayer(url: url)
            )
        }
    }
}

struct ClaimDetailFilesView_Previews: PreviewProvider {
    static var previews: some View {
        ClaimDetailFilesView(
            signedAudioURL: "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3"
        )
    }
}
