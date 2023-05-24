import Contracts
import Home
import Kingfisher
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SelectEntrypointNavigation: View {
    @State var subTitle = ""

    @PresentableStore var store: SubmitClaimStore
    public init() {
        store.send(.fetchEntrypointGroups)
    }

    public var body: some View {
        LoadingViewWithContent(.fetchClaimEntrypointGroups) {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.claimEntrypointGroups
                }
            ) { claimEntrypoint in
                
                hForm {
                    PresentableStoreLens(
                        HomeStore.self,
                        getter: { state in
                            state.memberStateData
                        }
                    ) { memberStateData in
                        if let name = memberStateData.name {
                            hText(L10n.claimTriagingAboutTitile(name), style: .prominentTitle)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.top, .bottom], 72)
                                .padding([.trailing, .leading], 16)
                        }
                    }
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
                                subTitle: "",
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

                    PresentableStoreLens(
                        ContractStore.self,
                        getter: { state in
                            state.contracts
                        }
                    ) { contracts in
                        ForEach(contracts, id: \.self) { contract in
                            if contract.currentAgreement?.status == .terminated {
                                VStack(spacing: 0) {
                                    TextBoxComponent(
                                        mainContent: hCoreUIAssets.pillowAccident.view
                                            .resizable()
                                            .frame(width: 48, height: 48),
                                        subTitle: "",
                                        topTitle: contract.displayName
                                    )
                                }
                                .padding([.trailing, .leading], 16)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                }.hUseNewStyle
            }
            .presentableStoreLensAnimation(.easeInOut)
        }
    }

    public func switchContent(entrypointGroup: ClaimEntryPointGroupResponseModel) -> some View {
        KFImage(URL(string: entrypointGroup.icon))
            .resizable()
            .frame(width: 48, height: 48)
    }

    @ViewBuilder
    public func returnBottomComponent() -> some View {
        hText("", style: .footnote)
            .foregroundColor(hLabelColor.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
