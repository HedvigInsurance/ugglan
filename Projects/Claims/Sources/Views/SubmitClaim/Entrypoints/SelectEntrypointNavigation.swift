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
                            .padding([.trailing, .leading, .bottom], 16)

                        ForEach(claimEntrypoint, id: \.self) { entrypointGroup in
                            let cardContent = switchContent(entrypointGroup: entrypointGroup)
                            CardComponent(
                                onSelected: {
                                    store.send(
                                        .entrypointGroupSelected(
                                            entrypointGroup: ClaimsOrigin.commonClaims(id: entrypointGroup.id)
                                        )
                                    )
                                },
                                mainContent: cardContent,
                                title: entrypointGroup.displayName,
                                text: "För skador som rör din lägenhet, dig själv, dina medförsäkrade och dina saker"
                            )
                        }
                    }
                }
            }
            .presentableStoreLensAnimation(.easeInOut)
        }
    }

    @ViewBuilder
    public func switchContent(entrypointGroup: ClaimEntryPointGroupResponseModel) -> some View {
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
