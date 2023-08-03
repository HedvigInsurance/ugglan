import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    @State var claim: Claim
    @PresentableStore var store: ClaimsStore

    public init(
        claim: Claim
    ) {
        self.claim = claim
    }

    private var statusParagraph: String {
        claim.claimDetailData.statusParagraph
    }

    /// Displays payout only if claim status is closed and outcome is paid. Nil otherwise and it won't be displayed
    private var payoutDisplayAmount: MonetaryAmount? {
        if case .closed = claim.claimDetailData.status,
            case .paid = claim.claimDetailData.outcome,
            !claim.claimDetailData.payout.amount.isEmpty
        {
            return claim.claimDetailData.payout
        }

        return nil
    }

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                ClaimDetailHeader(claim: claim)
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
                            status: self.claim.claimDetailData.status.rawValue
                        )
                        .padding(.bottom, 4)
                    }
                }
                if let url = URL(string: claim.claimDetailData.signedAudioURL) {
                    let audioPlayer = AudioPlayer(url: url)
                    hSection {
                        ClaimDetailFilesView(
                            audioPlayer: audioPlayer
                        )
                    }
                    .withHeader {
                        hText(L10n.ClaimStatusDetail.uploadedFiles)
                    }
                    .padding(.top, 8)
                    .onReceive(
                        audioPlayer.objectWillChange
                            .filter { $0.playbackState == .finished },
                        perform: { player in
                            hAnalyticsEvent.claimsDetailRecordingPlayed(
                                claimId: self.claim.id
                            )
                            .send()
                        }
                    )
                }
            }
        }
        .trackOnAppear(
            hAnalyticsEvent.screenView(screen: .claimsStatusDetail)
        )
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButtonGhost {
                    store.send(.closeClaimStatus)
                } content: {
                    hText(L10n.generalCloseButton)
                }
            }
            .sectionContainerStyle(.transparent)
        }

    }

}

struct ClaimDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let claimDetails = Claim.ClaimDetailData.init(
            id: "id",
            status: .closed,
            outcome: .paid,
            submittedAt: "2019-07-03T19:07:38.494081Z",
            closedAt: "2019-07-03T20:10:38.494081Z",
            signedAudioURL: "https://www.hedvig.com",
            progressSegments: [.init(text: "1", type: .futureInactive)],
            statusParagraph:
                "Status PARAGRAPH Status PARAGRAPH Status PARAGRAPH Status PARAGRAPH Status PARAGRAPH Status PARAGRAPH ",
            type: "TYPE",
            payout: .sek(20)
        )
        let claim = Claim(
            id: "id",
            pills: [.init(text: "1", type: .closed)],
            segments: [.init(text: "a", type: .pastInactive)],
            title: "title",
            subtitle: "subtitle",
            claimDetailData: claimDetails
        )
        return ClaimDetailView(claim: claim)
    }
}
