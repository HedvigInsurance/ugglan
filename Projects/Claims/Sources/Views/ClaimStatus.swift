import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    var claim: Claim

    @PresentableStore
    var store: ClaimsStore

    var tapAction: (Claim) -> Void {
        return { claim in
            store.send(.openClaimDetails(claim: claim))

            _ = hAnalyticsEvent.claimCardClick(
                claimId: self.claim.id,
                claimStatus: self.claim.claimDetailData.status.rawValue
            )
        }
    }

    var body: some View {
        CardComponent(
            onSelected: {
                tapAction(claim)
            },
            mainContent: ClaimPills(claim: claim),
            title: claim.title,
            subTitle: claim.subtitle,
            bottomComponent: {
                HStack(spacing: 6) {
                    ForEach(claim.segments, id: \.text) { segment in
                        ClaimStatusBar(status: segment)
                    }
                }
            }
        )
        .trackOnAppear(
            hAnalyticsEvent.claimCardVisible(
                claimId: self.claim.id,
                claimStatus: self.claim.claimDetailData.status.rawValue
            )
        )
    }
}

struct ClaimPills: View {
    var claim: Claim

    var body: some View {
        HStack {
            ForEach(claim.pills, id: \.text) { claimPill in
                hPillFill(
                    text: claimPill.text,
                    textColor: claimPill.type.textColor,
                    backgroundColor: claimPill.type.backgroundColor
                )
            }
        }
    }
}
extension Claim.ClaimPill.ClaimPillType {
    @hColorBuilder
    var textColor: some hColor {
        switch self {
        case .none: hTextColorNew.primary
        case .open: hTextColorNew.primary
        case .reopened: hSignalColorNew.amberText
        case .closed: hTextColorNew.negative
        case .payment: hSignalColorNew.blueText
        }
    }

    @hColorBuilder
    var backgroundColor: some hColor {
        switch self {
        case .none: hFillColorNew.opaqueTwo
        case .open: hFillColorNew.opaqueTwo
        case .reopened: hSignalColorNew.amberHighLight
        case .closed: hTextColorNew.primary
        case .payment: hSignalColorNew.blueHighLight
        }
    }
}

struct ClaimStatus_Previews: PreviewProvider {
    static var previews: some View {
        let data = GiraffeGraphQL.ClaimStatusCardsQuery.Data.init(
            claimsStatusCards: [
                .init(
                    id: "id",
                    pills: [
                        .init(text: "TEXT", type: .open),
                        .init(text: "TEXT 2", type: .closed),
                        .init(text: "TEXT 3", type: .payment),
                        .init(text: "TEXT 4", type: .reopened),
                    ],
                    title: "TITLE",
                    subtitle: "SUBTITLE",
                    progressSegments: [
                        .init(text: "STATUS 1", type: .currentlyActive),
                        .init(text: "Status 2", type: .futureInactive),
                        .init(text: "Status 3", type: .paid),
                        .init(text: "Status 4", type: .pastInactive),
                        .init(text: "Status 5", type: .reopened),
                    ],
                    claim: .init(
                        id: "ID",
                        submittedAt: "2023-11-23",
                        status: .beingHandled,
                        progressSegments: [.init(text: "PROGRESS", type: .currentlyActive)],
                        statusParagraph: "STATUS"
                    )
                )
            ]
        )
        let claimData = ClaimData(cardData: data)
        return VStack(spacing: 20) {
            ClaimStatus(claim: claimData.claims.first!)
            ClaimStatus(claim: claimData.claims.first!)
                .colorScheme(.dark)

        }
        .padding(20)
    }
}
