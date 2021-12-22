import SwiftUI
import hCore
import hCoreUI

struct ClaimDetailFilesView: View {
    let signedAudioURL: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = URL(string: signedAudioURL) {
                TrackPlayer(
                    audioPlayer: AudioPlayer(url: url)
                )
                .frame(height: 64)
            }
            hText(L10n.ClaimStatus.Files.claimAudioFooter, style: .footnote)
                .foregroundColor(hLabelColor.secondary)
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
