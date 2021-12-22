import SwiftUI
import hCore
import hCoreUI

struct ClaimDetailFilesView: View {
    let signedAudioURL: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // TODO: Add waveform to trackplayer
            if let url = URL(string: signedAudioURL) {
                TrackPlayer(
                    audioPlayer: .init(
                        recording: .init(
                            url: url,
                            created: Date(),
                            sample: []
                        )
                    )
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
            signedAudioURL:
                "https://com-hedvig-upload.s3.eu-central-1.amazonaws.com/eae30cd4-585c-4a06-9b51-7abb279c7bc2-0?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIZMW7F45HSE2X33Q%2F20211221%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20211221T124346Z&X-Amz-Expires=1800&X-Amz-Signature=a4c017c28fa82f1e7d792ae44453687ccd0fd763071d42319042b3ccde50a0cc&X-Amz-SignedHeaders=host"
        )
    }
}
