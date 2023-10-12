import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    var claim: ClaimModel
    
    @PresentableStore
    var store: ClaimsStore
    
    var tapAction: (ClaimModel) -> Void {
        return { claim in
            store.send(.openClaimDetails(claim: claim))
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
                    ForEach(ClaimModel.ClaimStatus.allCases, id: \.title) { segment in
                        if !(segment == .none || segment == .reopened) {
                            ClaimStatusBar(status: segment)
                        }
                    }
                }
            }
        )
    }
}

struct ClaimPills: View {
    var claim: ClaimModel
    
    var body: some View {
        HStack {
            hPillFill(
                text: claim.outcome.text.capitalized,
                textColor: claim.outcome.textColor,
                backgroundColor: claim.outcome.backgroundColor
            )
        }
    }
}
extension ClaimModel.ClaimOutcome {
    @hColorBuilder
    var textColor: some hColor {
        hTextColor.negative
    }
    
    @hColorBuilder
    var backgroundColor: some hColor {
        switch self {
        case .none:
            hColorScheme(light:  hFillColor.opaqueTwo, dark: hGrayscaleColor.greyScale400)
        default:
            hTextColor.primary
        }
    }
}

//struct ClaimStatus_Previews: PreviewProvider {
//    static var previews: some View {
//        let data = GiraffeGraphQL.ClaimStatusCardsQuery.Data.init(
//            claimsStatusCards: [
//                .init(
//                    id: "id",
//                    pills: [
//                        .init(text: "TEXT", type: .open),
//                        .init(text: "TEXT 2", type: .closed),
//                        .init(text: "TEXT 3", type: .payment),
//                        .init(text: "TEXT 4", type: .reopened),
//                    ],
//                    title: "TITLE",
//                    subtitle: "SUBTITLE",
//                    progressSegments: [
//                        .init(text: "STATUS 1", type: .currentlyActive),
//                        .init(text: "Status 2", type: .futureInactive),
//                        .init(text: "Status 3", type: .paid),
//                        .init(text: "Status 4", type: .pastInactive),
//                        .init(text: "Status 5", type: .reopened),
//                    ],
//                    claim: .init(
//                        id: "ID",
//                        submittedAt: "2023-11-23",
//                        status: .beingHandled,
//                        progressSegments: [.init(text: "PROGRESS", type: .currentlyActive)],
//                        statusParagraph: "STATUS"
//                    )
//                )
//            ]
//        )
//        let claimData = ClaimData(cardData: data)
//        return VStack(spacing: 20) {
//            ClaimStatus(claim: claimData.claims.first!)
//            ClaimStatus(claim: claimData.claims.first!)
//                .colorScheme(.dark)
//
//        }
//        .padding(20)
//    }
//}
