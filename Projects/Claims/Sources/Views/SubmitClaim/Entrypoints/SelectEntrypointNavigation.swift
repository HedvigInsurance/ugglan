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

                hFormNew {
                    hText(L10n.claimTriagingAboutTitile("Julia"), style: .prominentTitle)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 40)
                        .padding([.trailing, .leading], 16)

                    ForEach(claimEntrypoint, id: \.self) { entrypointGroup in
                        VStack(spacing: 0) {
                            TextBoxComponent(
                                onSelected: {
                                    store.send(
                                        .entrypointGroupSelected(
                                            entrypointGroup: ClaimsOrigin.commonClaims(id: entrypointGroup.id)
                                        )
                                    )
                                },
                                mainContent: switchContent(entrypointGroup: entrypointGroup),
                                subTitle: "subtitle here",
                                topTitle: entrypointGroup.displayName
                            )
                        }
                        .padding([.trailing, .leading], 16)
                        .padding(.bottom, 8)
                    }

                    hText(L10n.InsurancesTab.terminatedInsurancesLabel, style: .title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24)
                        .padding(.top, 72)
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

    @ViewBuilder
    public func returnBottomComponent() -> some View {
        hText("För skador som rör din lägenhet, dig själv, dina medförsäkrade och dina saker", style: .footnote)
            .foregroundColor(hLabelColor.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
