import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SelectEntrypointNavigation: View {
    @PresentableStore var store: SubmitClaimStore
    public init() {
        store.send(.fetchEntrypointGroups)
    }
    public var body: some View {
        LoadingViewWithContent(.fetchClaimEntrypoints) {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.claimEntrypointGroups
                }
            ) { claimEntrypoint in

                hForm {
                    VStack {
                        hText(L10n.claimTriagingNavigationTitle, style: .prominentTitle)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding([.trailing, .leading], 16)
                            .padding(.bottom, 30)
                        ForEach(claimEntrypoint, id: \.self) { entrypointGroup in
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .top, spacing: 0) {
                                    switch entrypointGroup.icon {
                                    case .home:
                                        hCoreUIAssets.pillowHome.view
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                    case .accident:
                                        hCoreUIAssets.pillowAccident.view
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                    case .car:
                                        hCoreUIAssets.pillowCar.view
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                    case .travel:
                                        hCoreUIAssets.pillowTravel.view
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                    }
                                    hText(entrypointGroup.displayName)
                                        .padding(.leading, 16)
                                    Spacer()
                                    hCoreUIAssets.chevronRight.view
                                }
                                .padding([.leading, .trailing, .top], 16)
                                Spacer().frame(height: 20)
                                SwiftUI.Divider()
                                    .padding([.leading, .trailing], 16)
                                hText(
                                    "För skador som rör din lägenhet, dig själv, dina medförsäkrade och dina saker",
                                    style: .footnote
                                )
                                .foregroundColor(hLabelColor.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(16)
                            }
                            .onTapGesture {
                                store.send(
                                    //                                    .entrypointGroupSelected(entrypointGroup: ClaimsOrigin.commonClaims(id: claimEntrypoint.id))
                                    .entrypointGroupSelected(entrypointGroup: ClaimsOrigin.commonClaims(id: "id"))
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(hBackgroundColor.primary)
                                    .hShadow()
                            )
                            .padding([.leading, .trailing], 16)
                            .padding([.top, .bottom], 8)
                        }
                    }
                }
            }
            .presentableStoreLensAnimation(.easeInOut)
        }
    }
}

extension Array {

    func chunked(by distance: Int) -> [[Element]] {
        precondition(distance > 0, "distance must be greater than 0")  // prevents infinite loop

        if self.count <= distance {
            return [self]
        } else {
            let head = [Array(self[0..<distance])]
            let tail = Array(self[distance..<self.count])
            return head + tail.chunked(by: distance)
        }
    }

}
