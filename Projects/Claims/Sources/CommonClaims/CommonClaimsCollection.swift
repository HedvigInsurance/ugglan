import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CommonClaimsCollection: View {
    @PresentableStore var store: ClaimsStore
    var commonClaims: [CommonClaim]

    init(
        commonClaims: [CommonClaim]
    ) {
        self.commonClaims = commonClaims
    }

    var body: some View {
        ForEach(commonClaims.chunked(into: 2), id: \.id) { claimsRow in
            HStack(spacing: 8) {
                ForEach(claimsRow, id: \.id) { claim in
                    Button {
                        store.send(.openCommonClaimDetail(commonClaim: claim))
                    } label: {

                    }
                    .buttonStyle(CommonClaimButtonStyle(claim: claim))
                }

                if claimsRow.count == 1 {
                    Spacer().frame(maxWidth: .infinity)
                }
            }
        }
    }
}

extension Array where Element == CommonClaim {
    var id: String {
        self.map { claim in claim.displayTitle }.joined(separator: "")
    }
}

struct CommonClaimButtonStyle: ButtonStyle {
    var claim: CommonClaim

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            HStack {
                if let icon = claim.icon {
                    RemoteVectorIconView(icon: icon, backgroundFetch: true)
                        .frame(width: 24, height: 24)
                }

                Spacer()
            }
            .padding(16)

            Spacer()

            hText(claim.displayTitle, style: .body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .padding(12)
        }
        .frame(maxWidth: .infinity)
        .background(hBackgroundColor.secondary)
        .cornerRadius(.defaultCornerRadius)
        .shadow(
            color: .black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
    }
}

struct CommonClaimsView: View {
    @PresentableStore var store: ClaimsStore
    
    var body: some View {
        VStack {
            hText(L10n.claimsQuickChoiceHeader, style: .title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 52)
                .padding(.bottom, 16)

            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    return state.commonClaims ?? []
                },
                setter: { _ in
                    .fetchCommonClaims
                }
            ) { commonClaims, _ in
                CommonClaimsCollection(commonClaims: commonClaims)
            }
        }
        .onAppear {
            store.send(.fetchCommonClaims)
        }
    }
}
