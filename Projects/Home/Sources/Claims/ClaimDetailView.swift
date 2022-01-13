import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    let claim: Claim

    var store: HomeStore

    public init(
        claim: Claim
    ) {
        self.claim = claim
        let store: HomeStore = globalPresentableStoreContainer.get()
        self.store = store
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

                ContactChatView(store: self.store)
            }
            .padding(.horizontal, 16)

            Spacer()
                .frame(height: 52)

            // Section to show attachments for the claim
            if let url = URL(string: claim.claimDetailData.signedAudioURL) {
                ClaimDetailFilesView(
                    audioPlayer: AudioPlayer(url: url)
                )
                .padding(.horizontal, 16)
            }

            Spacer()
        }
        .background(hBackgroundColor.primary)
        .navigationBarTitle(Text(L10n.ClaimStatus.title), displayMode: .inline)
    }
}
