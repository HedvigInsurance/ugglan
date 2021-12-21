import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    let claim: Claim

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
            ClaimDetailHeader(
                title: claim.title,
                subtitle: claim.subtitle,
                submitted: claim.claimDetailData.submittedAt,
                closed: claim.claimDetailData.closedAt,
                payout: payoutDisplayAmount
            )
            .padding(.vertical, 24)

            // Status card section
            TappableCard(alignment: .leading) {
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

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        hText(L10n.ClaimStatus.Contact.Generic.subtitle, style: .caption1)
                            .foregroundColor(hLabelColor.secondary)
                        hText(L10n.ClaimStatus.Contact.Generic.title, style: .callout)
                    }
                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: .defaultCornerRadius)
                            .fill(hBackgroundColor.primary)
                            .frame(width: 40, height: 40)

                        hCoreUIAssets.chatSolid.view
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 23, height: 19)
                    }
                    .onTapGesture {
                        print("Tapped the chat button")
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 16)

            Spacer()
                .frame(height: 52)

            // Audio files section
            VStack(alignment: .leading, spacing: 8) {
                // TODO: Add waveform to trackplayer
                if let url = URL(string: claim.claimDetailData.signedAudioURL) {
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
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(hBackgroundColor.primary)
        .navigationBarTitle(Text(L10n.ClaimStatus.title), displayMode: .inline)
    }
}
