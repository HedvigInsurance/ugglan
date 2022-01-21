import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    @State var claim: Claim
    @PresentableStore var store: HomeStore

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
            // Header for Claim status details
            ClaimDetailHeader(
                title: claim.title,
                subtitle: claim.subtitle,
                submitted: claim.claimDetailData.submittedAt,
                closed: claim.claimDetailData.closedAt,
                payout: payoutDisplayAmount
            )
            .padding(.vertical, 24)

            // Card showing the status of claim
            RaisedCard(alignment: .leading) {
                HStack(spacing: 6) {
                    ForEach(claim.segments, id: \.text) { segment in
                        ClaimStatusBar(status: segment)
                    }
                }
                .padding([.horizontal, .top], 16)
                .padding(.bottom, 24)

                hText(statusParagraph)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                Divider()

                ContactChatView(
                    store: self.store,
                    id: self.claim.id,
                    status: self.claim.claimDetailData.status.rawValue
                )
            }
            .padding(.horizontal, 16)

            Spacer()
                .frame(height: 52)

            // Section to show attachments for the claim
            if let url = URL(string: claim.claimDetailData.signedAudioURL) {
                let audioPlayer = AudioPlayer(url: url)
                ClaimDetailFilesView(
                    audioPlayer: audioPlayer
                )
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
                .padding(.horizontal, 16)
            }

            Spacer()
        }
        .trackOnAppear(
            hAnalyticsEvent.claimsStatusDetailScreenView(
                claimId: self.claim.id,
                claimStatus: self.claim.claimDetailData.status.rawValue
            )
        )
    }
}
