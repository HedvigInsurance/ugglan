import SwiftUI
import hCore
import hCoreUI

struct TravelInsuranceContractsScreen: View {
    @PresentableStore var store: TravelInsuranceStore
    public var body: some View {
        TravelInsuranceLoadingView(.getTravelInsurance) {
            PresentableStoreLens(
                TravelInsuranceStore.self,
                getter: { state in
                    state.travelInsuranceConfig
                }
            ) { travelInsuranceConfig in
                PresentableStoreLens(
                    TravelInsuranceStore.self,
                    getter: { state in
                        state.travelInsuranceConfigs ?? []
                    }
                ) { travelInsuranceModels in
                    if !travelInsuranceModels.isEmpty  {
                        hForm {
                            hTextNew(L10n.TravelCertificate.selectContractTitle, style: .title3)
                                .padding(.vertical, 100)
                                .padding(.horizontal, 16)
                                .multilineTextAlignment(.center)
                            ForEach(travelInsuranceModels, id: \.contractId) { item in
                                hSection {
                                    hRow {
                                        HStack {
                                            hCoreUIAssets.pillowHome.view.resizable().frame(width: 48, height: 48)
                                            hText(item.street)
                                        }
                                    }.withCustomAccessory {
                                        getCustomAccessory(item: item, and: travelInsuranceConfig)
                                    }.onTap {
                                        store.send(.setTravelInsuranceData(config: item))
                                    }
                                }
                                .sectionContainerStyle(.opaqueNew)
                            }
                        }
                        .hFormAttachToBottom {
                            hButton.LargeButtonFilled {
                                let email = travelInsuranceConfig?.email ?? ""
                                store.send(.navigation(.openEmailScreen(email: email)))
                            } content: {
                                hText(L10n.generalContinueButton)
                            }
                            .padding([.leading, .trailing], 16)
                            .padding(.bottom, 6)
                        }
                        .navigationTitle(L10n.TravelCertificate.cardTitle)
                        .hUseNewStyle
                    }
                }
            }.presentableStoreLensAnimation(.spring())
            
        }
    }
    
    @ViewBuilder
    private func getCustomAccessory(item: TravelInsuranceConfig, and selectedOne: TravelInsuranceConfig?) -> some View {
        HStack {
            Spacer()
            if item.contractId == selectedOne?.contractId {
                Circle().fill(hLabelColorNew.primary).frame(width: 22, height: 22)
            } else  {
                Circle().stroke(hLabelColorNew.tertiary)
                    .frame(width: 22, height: 22)
            }
        }
    }
}

struct TravelInsuranceContractsScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceContractsScreen()
    }
}
