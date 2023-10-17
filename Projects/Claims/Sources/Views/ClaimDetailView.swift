import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    @State var claim: ClaimModel
    @PresentableStore var store: ClaimsStore

    public init(
        claim: ClaimModel
    ) {
        self.claim = claim
    }

    private var statusParagraph: String {
        claim.statusParagraph
    }

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                ClaimStatus(claim: claim, enableTap: false)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                hSection {
                    hRow {
                        hText(statusParagraph)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                    hRow {
                        ContactChatView(
                            store: self.store,
                            id: self.claim.id,
                            status: self.claim.status.rawValue
                        )
                        .padding(.bottom, 4)
                    }
                }
                if let url = URL(string: claim.signedAudioURL) {
                    let audioPlayer = AudioPlayer(url: url)
                    hSection {
                        ClaimDetailFilesView(
                            audioPlayer: audioPlayer
                        )
                    }
                    .withHeader {
                        hText(L10n.ClaimStatusDetail.uploadedFiles)
                            .padding(.leading, 2)
                    }
                    .padding(.top, 16)
                    .onReceive(
                        audioPlayer.objectWillChange
                            .filter { $0.playbackState == .finished },
                        perform: { player in
                        }
                    )
                } else if let inputText = claim.memberFreeText {
                    hSection {
                        hRow {
                            hText(inputText)
                        }
                    }
                    .withHeader {
                        hText("Submitted message")
                            .padding(.leading, 2)
                    }
                    .padding(.top, 16)

                }
            }
        }
    }

}

struct ClaimDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let claim = ClaimModel(
            id: "2",
            status: .closed,
            outcome: .notCovered,
            submittedAt: "2023-10-10",
            closedAt: nil,
            signedAudioURL: "",
            type: "",
            memberFreeText: nil
        )
        return ClaimDetailView(claim: claim)
    }
}
