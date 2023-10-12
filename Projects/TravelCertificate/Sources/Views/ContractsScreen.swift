import SwiftUI
import hCore
import hCoreUI

struct ContractsScreen: View {
    @PresentableStore var store: TravelInsuranceStore
    public var body: some View {
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
                if !travelInsuranceModels.isEmpty {
                    hForm {
                        VStack(spacing: 4) {
                            ForEach(travelInsuranceModels, id: \.contractId) { item in
                                getContractView(for: item, and: travelInsuranceConfig)
                            }
                        }
                    }
                    .hFormTitle(.standard, .title3, L10n.TravelCertificate.selectContractTitle)
                    .hFormAttachToBottom {
                        hButton.LargeButton(type: .primary) {
                            store.send(.navigation(.openStartDateScreen))
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                    }
                    .navigationTitle(L10n.TravelCertificate.cardTitle)
                }
            }
        }
        .presentableStoreLensAnimation(.spring())
        .trackLoading(TravelInsuranceStore.self, action: .getTravelInsurance)
    }

    private func getContractView(
        for item: TravelInsuranceContractSpecification,
        and selectedOne: TravelInsuranceContractSpecification?
    ) -> some View {
        hSection {
            hRow {
                HStack {
                    hCoreUIAssets.pillowHome.view.resizable().frame(width: 48, height: 48)
                    hText(item.street)
                }
            }
            .withCustomAccessory {
                getCustomAccessory(item: item, and: selectedOne)
            }
            .onTap {
                store.send(.setTravelInsuranceData(specification: item))
            }
        }
        .sectionContainerStyle(.opaque)
    }

    @ViewBuilder
    private func getCustomAccessory(
        item: TravelInsuranceContractSpecification,
        and selectedOne: TravelInsuranceContractSpecification?
    ) -> some View {
        HStack {
            Spacer()
            if item.contractId == selectedOne?.contractId {
                Circle().fill(hTextColor.primary).frame(width: 22, height: 22)
            } else {
                Circle().stroke(hTextColor.tertiary)
                    .frame(width: 22, height: 22)
            }
        }
    }
}

struct TravelInsuranceContractsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContractsScreen()
    }
}
