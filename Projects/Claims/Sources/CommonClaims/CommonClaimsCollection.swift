import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL
public typealias GetClaimDataClosure = (_ forClaim: CommonClaim, _ completed: (CommonClaim) -> Void) -> Void
struct CommonClaimsCollection: View {
    @PresentableStore var store: ClaimsStore
    @State var isLoading = false
    var commonClaims: [CommonClaim]
    let getClaimData: GetClaimDataClosure
    init(
        commonClaims: [CommonClaim],
        getClaimData: @escaping GetClaimDataClosure
    ) {
        self.commonClaims = commonClaims
        self.getClaimData = getClaimData
    }

    var body: some View {
        VStack {
            ForEach(commonClaims.chunked(into: 2), id: \.id) { claimsRow in
                HStack(spacing: 8) {
                    ForEach(claimsRow, id: \.id) { claim in
                        Button {
                            if claim.id == ClaimsState.travelInsuranceCommonClaim.id {
                                isLoading = true
                                getClaimData(claim) { newClame in
                                    isLoading = false
                                    store.send(.openCommonClaimDetail(commonClaim: newClame))
                                }
                            } else {
                                store.send(.openCommonClaimDetail(commonClaim: claim))
                            }
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
                }else if let imageName = claim.imageName {
                    Image(imageName, bundle: ClaimsResources.bundle)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24).clipShape(Circle())
                        .foregroundColor(hLabelColor.primary)
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
        .clipShape(Squircle.default())
        .shadow(
            color: .black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
    }
}

public struct CommonClaimsView: View {
    @PresentableStore var store: ClaimsStore
    private let getClaimData: GetClaimDataClosure
    public init(
        getClaimData: @escaping GetClaimDataClosure
    ) {
        self.getClaimData = getClaimData
    }
    public var body: some View {
        hSection {
            hRow {
                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        return state.getRecommendedForYou
                    },
                    setter: { _ in
                        .fetchCommonClaims
                    }
                ) { commonClaims, _ in
                    CommonClaimsCollection(commonClaims: commonClaims, getClaimData: getClaimData)
                }
            }
            .noSpacing()
        }
        .withHeader {
            hText(
                L10n.claimsQuickChoiceHeader,
                style: .title2
            )
        }
        .sectionContainerStyle(.transparent)
        .onAppear {
            store.send(.fetchCommonClaims)
        }
    }
}
