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
                        state.travelInsuranceConfigs?.travelCertificateSpecifications ?? []
                    }
                ) { travelInsuranceModels in
                    if !travelInsuranceModels.isEmpty  {
                        hForm {
                            hTextNew(L10n.TravelCertificate.selectContractTitle, style: .title3)
                                .padding(.vertical, 100)
                                .padding(.horizontal, 16)
                                .multilineTextAlignment(.center)
                            ForEach(travelInsuranceModels, id: \.contractId) { item in
                                getContractView(for: item, and: travelInsuranceConfig)
                            }
                        }
                        .hFormAttachToBottom {
                            hButton.LargeButtonFilled {
                                store.send(.navigation(.openTravelInsuranceForm))
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
    
    private func getContractView(for item: TravelInsuranceContractSpecification, and selectedOne: TravelInsuranceContractSpecification?) -> some View {
        hSection {
            hRow {
                HStack {
                    hCoreUIAssets.pillowHome.view.resizable().frame(width: 48, height: 48)
                    hText(item.street)
                }
            }.withCustomAccessory {
                getCustomAccessory(item: item, and: selectedOne)
            }.onTap {
                store.send(.setTravelInsuranceData(specification: item))
            }
        }
        .sectionContainerStyle(.opaque(useNewDesign: true))
    }
    
    @ViewBuilder
    private func getCustomAccessory(item: TravelInsuranceContractSpecification, and selectedOne: TravelInsuranceContractSpecification?) -> some View {
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
