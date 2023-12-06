import SwiftUI
import hCore
import hCoreUI

struct ContractsScreen: View {
    @PresentableStore var store: TravelInsuranceStore
    @State var isLoading: Bool = false
    
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
                    CheckboxPickerScreen<TravelInsuranceContractSpecification>(
                        items: {
                            return travelInsuranceModels.map {
                                (object: $0, displayName: $0.street)
                            }
                        }(),
                        preSelectedItems: {
                            guard let preSelected = travelInsuranceModels.first else {
                             return []
                            }
                            return [preSelected]
                        },
                        onSelected: { selected in
                            if let selected = selected.first {
                                store.send(.setTravelInsuranceData(specification: selected))
                                store.send(.navigation(.openStartDateScreen))
                            }
                        },
                        singleSelect: true,
                        attachToBottom: true,
                        hButtonText: L10n.generalContinueButton
                    )
                    .hFormTitle(.standard, .title1, L10n.TravelCertificate.selectContractTitle)
                    .hButtonIsLoading(isLoading)
                    .hDisableScroll
                    .onReceive(
                        store.loadingSignal
                            .plain()
                            .publisher
                    ) { value in
                        withAnimation {
                            isLoading = value[.getTravelInsurance] == .loading
                        }
                    }
                }
            }
        }
        .presentableStoreLensAnimation(.spring())
        .trackLoading(TravelInsuranceStore.self, action: .getTravelInsurance)
    }
}

struct TravelInsuranceContractsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContractsScreen()
    }
}
