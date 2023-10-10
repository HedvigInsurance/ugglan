import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimDetailHeader: View {
    private let claim: ClaimModel

    init(claim: ClaimModel) {
        self.claim = claim
    }
    var body: some View {
        hSection {
            CardComponent(
                mainContent: ClaimPills(claim: claim),
                title: claim.title,
                subTitle: claim.subtitle,
                bottomComponent: {
                    bottomView
                }
            )
        }
    }

    @ViewBuilder
    private var bottomView: some View {
        if let submittedAt = claim.claimDetailData.submittedAt,
            let closedAt = claim.claimDetailData.closedAt
        {
            HStack {
                VStack(alignment: .leading) {
                    hText(L10n.ClaimStatusDetail.submitted)
                    hText(submittedAt.localDateToIso8601Date?.localDateStringWithTime ?? "--")
                        .foregroundColor(hTextColor.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .leading) {
                    hText(L10n.ClaimStatusDetail.closed)
                    hText(closedAt.localDateToIso8601Date?.localDateStringWithTime ?? "--")
                        .foregroundColor(hTextColor.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        } else {
            HStack(spacing: 6) {
                ForEach(claim.segments, id: \.text) { segment in
                    ClaimStatusBar(status: segment)
                }
            }
        }
    }
}
